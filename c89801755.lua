--深淵の指名者
-- 效果：
-- 支付1000基本分。种族和属性各宣言一样。对方从手卡·卡组选取宣言的种族和属性2样1致的1张怪兽卡送去墓地。
function c89801755.initial_effect(c)
	-- 支付1000基本分。种族和属性各宣言一样。对方从手卡·卡组选取宣言的种族和属性2样1致的1张怪兽卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(c89801755.cost)
	e1:SetTarget(c89801755.target)
	e1:SetOperation(c89801755.activate)
	c:RegisterEffect(e1)
end
-- 支付1000基本分的Cost处理
function c89801755.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除发动玩家1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果发动时的目标选择与宣言处理
function c89801755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示发动玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让发动玩家宣言1个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	-- 提示发动玩家选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让发动玩家宣言1个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(att)
	-- 将效果的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将宣言的种族作为效果参数保存
	Duel.SetTargetParam(rc)
	-- 设置连锁操作信息为“对方从手卡或卡组将1张卡送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤出满足宣言的种族和属性且能送去墓地的怪兽卡
function c89801755.filter(c,rc,att)
	return c:IsRace(rc) and c:IsAttribute(att) and c:IsAbleToGrave()
end
-- 效果处理的执行函数
function c89801755.activate(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	-- 获取当前连锁的对象玩家（对方）和保存的种族参数
	local p,rc=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 提示对方玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让对方玩家从自己的手卡或卡组中选择1张满足宣言种族和属性的怪兽卡
	local g=Duel.SelectMatchingCard(p,c89801755.filter,p,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,rc,att)
	if g:GetCount()>0 then
		-- 将选取的怪兽卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
