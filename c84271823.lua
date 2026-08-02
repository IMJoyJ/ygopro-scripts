--落消しのパズロミノ
-- 效果：
-- 等级不同的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡已在怪兽区域存在的状态，这张卡所连接区有怪兽表侧表示特殊召唤的场合，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
-- ②：从自己和对方的场上以相同等级的怪兽各1只为对象才能发动。那些怪兽破坏。
function c84271823.initial_effect(c)
	-- 添加连接召唤手续
	aux.AddLinkProcedure(c,c84271823.mfilter,2,2,c84271823.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡已在怪兽区域存在的状态，这张卡所连接区有怪兽表侧表示特殊召唤的场合，宣言1～8的任意等级才能发动。那只怪兽直到回合结束时变成宣言的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84271823,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,84271823)
	e1:SetCondition(c84271823.lvcon)
	e1:SetTarget(c84271823.lvtg)
	e1:SetOperation(c84271823.lvop)
	c:RegisterEffect(e1)
	-- ②：从自己和对方的场上以相同等级的怪兽各1只为对象才能发动。那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84271823,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,84271824)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c84271823.destg)
	e2:SetOperation(c84271823.desop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：等级在1星以上的怪兽
function c84271823.mfilter(c)
	return c:IsLevelAbove(0)
end
-- 连接素材检查：检查素材怪兽的等级各不相同
function c84271823.lcheck(g,lc)
	return g:GetClassCount(Card.GetLevel)==g:GetCount()
end
-- 效果①过滤条件：检查怪兽是否表侧表示、有等级且在连接区内
function c84271823.cfilter(c,lg)
	return c:IsFaceup() and c:IsLevelAbove(0) and lg:IsContains(c)
end
-- 效果①的发动条件：这张卡没有被特殊召唤且特殊召唤的怪兽中存在这张卡所连接区的怪兽
function c84271823.lvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(c84271823.cfilter,1,nil,c:GetLinkedGroup())
end
-- 效果①的目标选择：获取满足条件的怪兽，计算它们所没有的等级（1-8），让玩家宣言其中一个等级
function c84271823.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local g=eg:Filter(c84271823.cfilter,nil,c:GetLinkedGroup())
	g:KeepAlive()
	local ct={}
	for i=1,8 do
		if not g:IsExists(Card.IsLevel,1,nil,i) then table.insert(ct,i) end
	end
	-- 提示玩家选择一个等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家从计算出的可宣言等级中选择并宣言一个数字
	local lv=Duel.AnnounceNumber(tp,table.unpack(ct))
	e:SetLabel(lv)
	e:SetLabelObject(g)
end
-- 效果①的处理过滤条件：表侧表示、有等级且等级不等于宣言等级的怪兽
function c84271823.efilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(0) and not c:IsLevel(lv)
end
-- 效果①的处理：如果满足条件的怪兽大于1只，则让玩家选择1只；将其等级变成宣言的等级直到回合结束
function c84271823.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local g=e:GetLabelObject()
	local tg=g:Filter(c84271823.efilter,nil,lv)
	local tc=tg:GetFirst()
	if #g>2 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=tg:Select(tp,1,1,nil):GetFirst()
	end
	g:DeleteGroup()
	if tc then
		-- 那只怪兽直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的目标过滤条件1：表侧表示且有等级，并且对方场上存在与之相同等级的怪兽
function c84271823.tgfilter1(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(0)
		-- 检查对方场上是否存在与该怪兽等级相同、表侧表示且可以成为效果对象的怪兽
		and Duel.IsExistingMatchingCard(c84271823.tgfilter2,tp,0,LOCATION_MZONE,1,nil,e,c:GetLevel())
end
-- 效果②的目标过滤条件2：表侧表示、等级等于选定怪兽的等级且可以成为效果对象
function c84271823.tgfilter2(c,e,lv)
	return c:IsFaceup() and c:IsLevelAbove(0) and c:IsLevel(lv) and c:IsCanBeEffectTarget(e)
end
-- 效果②的目标选择：分别从自己和对方场上选择1只同等级怪兽作为对象，并设置破坏操作信息
function c84271823.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否能从己方场上选出1只满足过滤条件1的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c84271823.tgfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择自己场上要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1只满足过滤条件1的怪兽作为对象
	local g1=Duel.SelectTarget(tp,c84271823.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 提示玩家选择对方场上要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只与己方选择怪兽同等级满足过滤条件2的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c84271823.tgfilter2,tp,0,LOCATION_MZONE,1,1,nil,e,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 设置破坏操作信息，预计破坏选定的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果②的处理：获取对象卡，若其仍在场上则将它们破坏
function c84271823.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将满足条件的怪兽破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
