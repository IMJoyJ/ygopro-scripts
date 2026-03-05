--ライトニング・ストーム
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上没有表侧表示卡存在的场合，可以从以下效果选择1个发动。
-- ●对方场上的攻击表示怪兽全部破坏。
-- ●对方场上的魔法·陷阱卡全部破坏。
function c14532163.initial_effect(c)
	-- 创建效果并设置其分类为破坏、类型为发动、时点为自由时点、发动次数限制为1次且不能与誓约共用、条件为c14532163.condition、目标为c14532163.target、效果处理为c14532163.activate
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
-- 效果条件函数，判断自己场上是否没有表侧表示的卡
function c14532163.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有卡的组
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	local sg=g:Filter(Card.IsFaceup,nil)
	return sg:GetCount()<=0
end
-- 效果目标函数，用于判断是否可以发动效果并选择破坏对象
function c14532163.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断对方场上是否存在攻击表示的怪兽
	local b1=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0):Filter(Card.IsPosition,nil,POS_ATTACK):GetCount()>0
	-- 判断对方场上是否存在魔法或陷阱卡
	local b2=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_ONFIELD,c,TYPE_SPELL+TYPE_TRAP)>0
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 选择破坏对方场上攻击表示怪兽的效果
		s=Duel.SelectOption(tp,aux.Stringid(14532163,0))  --"对方场上的攻击表示怪兽全部破坏"
	end
	if not b1 and b2 then
		-- 选择破坏对方场上魔法·陷阱卡的效果
		s=Duel.SelectOption(tp,aux.Stringid(14532163,1))+1  --"对方场上的魔法·陷阱卡全部破坏"
	end
	if b1 and b2 then
		-- 选择破坏对方场上攻击表示怪兽或魔法·陷阱卡的效果
		s=Duel.SelectOption(tp,aux.Stringid(14532163,0),aux.Stringid(14532163,1))  --"对方场上的攻击表示怪兽全部破坏" / "对方场上的魔法·陷阱卡全部破坏"
	end
	e:SetLabel(s)
	local g=nil
	if s==0 then
		-- 获取对方场上攻击表示的怪兽组
		g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	end
	if s==1 then
		-- 获取对方场上魔法·陷阱卡的组
		g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,c,TYPE_SPELL+TYPE_TRAP)
	end
	-- 设置操作信息，确定要破坏的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数，执行破坏效果
function c14532163.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=nil
	if e:GetLabel()==0 then
		-- 获取对方场上攻击表示的怪兽组
		g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_ATTACK)
	end
	if e:GetLabel()==1 then
		-- 获取对方场上魔法·陷阱卡的组（排除此卡）
		g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e),TYPE_SPELL+TYPE_TRAP)
	end
	if g:GetCount()>0 then
		-- 将指定卡组以效果原因破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
