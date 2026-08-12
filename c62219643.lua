--逢華妖麗譚－魔妖不知火語
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把自己场上1只「魔妖」同调·连接怪兽或者「不知火」同调·连接怪兽解放才能发动。这个回合，双方不能从手卡·卡组·额外卡组把怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以除外的1只自己的不死族怪兽为对象才能发动。那只怪兽回到墓地。
function c62219643.initial_effect(c)
	-- ①：把自己场上1只「魔妖」同调·连接怪兽或者「不知火」同调·连接怪兽解放才能发动。这个回合，双方不能从手卡·卡组·额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,62219643)
	e1:SetCost(c62219643.limcost)
	e1:SetOperation(c62219643.limop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的1只自己的不死族怪兽为对象才能发动。那只怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,62219643)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c62219643.tgtg)
	e2:SetOperation(c62219643.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上的「魔妖」或「不知火」同调·连接怪兽
function c62219643.rfilter(c,tp)
	return c:IsSetCard(0x121,0xd9) and c:IsType(TYPE_SYNCHRO+TYPE_LINK) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果①的发动代价：解放自己场上1只满足条件的怪兽
function c62219643.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c62219643.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c62219643.rfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果①的效果处理：给双方玩家注册不能从手卡·卡组·额外卡组特殊召唤怪兽的限制
function c62219643.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，双方不能从手卡·卡组·额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c62219643.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局环境注册该特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
	-- ②：把墓地的这张卡除外，以除外的1只自己的不死族怪兽为对象才能发动。那只怪兽回到墓地。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(63060238)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册特定的效果标识（用于其他卡片判定此效果是否已适用）
	Duel.RegisterEffect(e2,tp)
end
-- 限制特殊召唤的区域为手卡、卡组、额外卡组
function c62219643.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤条件：除外的表侧表示的不死族怪兽且能送去墓地
function c62219643.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsFaceup() and c:IsAbleToGrave()
end
-- 效果②的靶向与发动准备：选择除外的1只自己的不死族怪兽为对象
function c62219643.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c62219643.tgfilter(chkc) end
	-- 检查除外区是否存在至少1只满足条件的自己的不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c62219643.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择除外的1只满足条件的不死族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62219643.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②的效果处理：使作为对象的怪兽回到墓地
function c62219643.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
