--覇魔導士アーカナイト・マジシャン
-- 效果：
-- 魔法师族同调怪兽＋魔法师族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡融合召唤成功的场合发动。给这张卡放置2个魔力指示物。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×1000。
-- ③：1回合1次，可以把自己场上1个魔力指示物取除，从以下效果选择1个发动。
-- ●以场上1张卡为对象才能发动。那张卡破坏。
-- ●自己从卡组抽1张。
function c21113684.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「魔法师族同调怪兽」和「魔法师族怪兽」各1只为融合素材
	aux.AddFusionProcFun2(c,c21113684.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),true)
	-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c21113684.attackup)
	c:RegisterEffect(e2)
	-- ①：这张卡融合召唤成功的场合发动。给这张卡放置2个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21113684,0))  --"放置魔力指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c21113684.addcc)
	e3:SetTarget(c21113684.addct)
	e3:SetOperation(c21113684.addc)
	c:RegisterEffect(e3)
	-- ③：1回合1次，可以把自己场上1个魔力指示物取除，从以下效果选择1个发动。●以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21113684,1))  --"场上1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(c21113684.cost)
	e4:SetTarget(c21113684.destg)
	e4:SetOperation(c21113684.desop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，可以把自己场上1个魔力指示物取除，从以下效果选择1个发动。●自己从卡组抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(21113684,2))  --"抽1张卡"
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCost(c21113684.cost)
	e5:SetTarget(c21113684.drtg)
	e5:SetOperation(c21113684.drop)
	c:RegisterEffect(e5)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EFFECT_SPSUMMON_CONDITION)
	e6:SetValue(c21113684.splimit)
	c:RegisterEffect(e6)
end
c21113684.material_type=TYPE_SYNCHRO
c21113684.mentioned_counter={
	[0x1]=true,
}
-- 特殊召唤限制：这张卡在额外卡组时只能用融合召唤特殊召唤，在其它位置则不受限制
function c21113684.splimit(e,se,sp,st)
	if e:GetHandler():IsLocation(LOCATION_EXTRA) then
		return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
	end
	return true
end
-- 融合素材过滤函数：检查卡片是否为魔法师族的同调怪兽（作为融合素材之一）
function c21113684.ffilter(c)
	return c:IsFusionType(TYPE_SYNCHRO) and c:IsRace(RACE_SPELLCASTER)
end
-- 攻击力上升值计算：返回这张卡的魔力指示物数量×1000的数值
function c21113684.attackup(e,c)
	return c:GetCounter(0x1)*1000
end
-- 发动条件检查：这张卡是融合召唤成功的场合才能发动
function c21113684.addcc(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果对象处理：必发效果无需检查，设置操作信息为给这张卡放置2个魔力指示物
function c21113684.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理将给卡片放置2个魔力指示物（CATEGORY_COUNTER）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 效果处理：若这张卡仍与此效果关联，则给这张卡放置2个魔力指示物
function c21113684.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 代价处理：发动时需能取除自己场上1个魔力指示物，向对方提示选择的效果并实际取除1个魔力指示物作为代价
function c21113684.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己场上是否存在可以取除的1个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) end
	-- 向对方玩家提示：对方选择发动了哪个效果（破坏或抽卡）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 作为代价取除自己场上1个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,1,REASON_COST)
end
-- 对象选择处理：检查场上是否存在可成为对象的卡，提示并选择场上1张卡为对象，设置破坏的操作信息
function c21113684.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动可行性检查：场上是否存在1张可以成为这个效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家发送选择提示：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为这个效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次连锁处理将破坏作为对象的1张卡（CATEGORY_DESTROY）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与此效果关联则以效果将其破坏
function c21113684.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象的那张卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 对象选择处理：确认自己可以抽1张卡，设定对象玩家和抽卡数量，设置抽卡的操作信息
function c21113684.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 把当前连锁的对象玩家设定为自己
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁的对象参数设定为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置操作信息：本次连锁处理自己将抽1张卡（CATEGORY_DRAW）
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息取得对象玩家和抽卡数量，让该玩家抽相应数量的卡
function c21113684.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象玩家和对象参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
