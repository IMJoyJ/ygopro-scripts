--ライトニング・ストーム
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上没有表侧表示卡存在的场合，可以从以下效果选择1个发动。
-- ●对方场上的攻击表示怪兽全部破坏。
-- ●对方场上的魔法·陷阱卡全部破坏。
function c14532163.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上没有表侧表示卡存在的场合，可以从以下效果选择1个发动。●对方场上的攻击表示怪兽全部破坏。●对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14532163+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c14532163.condition)
	e1:SetTarget(c14532163.target)
	e1:SetOperation(c14532163.activate)
	c:RegisterEffect(e1)
end
-- 判断发动条件：自己场上没有表侧表示卡存在时，该效果可以发动（满足条件返回true）。
function c14532163.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上全部卡片（怪兽区与魔陷区，含表侧与里侧）。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	local sg=g:Filter(Card.IsFaceup,nil)
	return sg:GetCount()<=0
end
-- 效果发动时的目标选择与合法性判定：确认两种破坏对象是否存在，让玩家选择使用的效果分支，并记录选择结果及设置破坏的操作信息。
function c14532163.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方主要怪兽区是否存在攻击表示的怪兽，作为可选分支1的前提条件。
	local b1=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0):Filter(Card.IsPosition,nil,POS_ATTACK):GetCount()>0
	-- 检查对方场上是否存在魔法·陷阱卡，作为可选分支2的前提条件。
	local b2=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_ONFIELD,c,TYPE_SPELL+TYPE_TRAP)>0
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 当仅可选择破坏攻击表示怪兽时，让玩家选择该选项（返回0）。
		s=Duel.SelectOption(tp,aux.Stringid(14532163,0))  --"对方场上的攻击表示怪兽全部破坏"
	end
	if not b1 and b2 then
		-- 当仅可选择破坏魔法·陷阱卡时，让玩家选择该选项，并将返回值映射为1。
		s=Duel.SelectOption(tp,aux.Stringid(14532163,1))+1  --"对方场上的魔法·陷阱卡全部破坏"
	end
	if b1 and b2 then
		-- 当两个分支都可用时，让玩家在‘破坏攻击表示怪兽’和‘破坏魔法·陷阱卡’中二选一，返回0或1。
		s=Duel.SelectOption(tp,aux.Stringid(14532163,0),aux.Stringid(14532163,1))  --"对方场上的攻击表示怪兽全部破坏/对方场上的魔法·陷阱卡全部破坏"
	end
	e:SetLabel(s)
	local g=nil
	if s==0 then
		-- 根据选择的分支0，获取对方场上所有攻击表示怪兽，作为待破坏对象。
		g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	end
	if s==1 then
		-- 根据选择的分支1，获取对方场上的魔法·陷阱卡（不包含本卡自身），作为待破坏对象。
		g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,c,TYPE_SPELL+TYPE_TRAP)
	end
	-- 登记本次效果将破坏的对象及数量，供连锁判定等系统使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：根据发动时选择的分支，重新获取对应的对象并将其全部破坏。
function c14532163.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	if e:GetLabel()==0 then
		-- 处理分支0：重新获取对方场上所有攻击表示怪兽。
		g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	end
	if e:GetLabel()==1 then
		-- 处理分支1：重新获取对方场上的魔法·陷阱卡，并排除效果发动中的这张卡自身。
		g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e),TYPE_SPELL+TYPE_TRAP)
	end
	if g:GetCount()>0 then
		-- 将取得的目标卡全部破坏，破坏原因为效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
