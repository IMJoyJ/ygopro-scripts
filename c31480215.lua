--幻獣機ウォーブラン
-- 效果：
-- 这张卡作为机械族怪兽的同调召唤的素材送去墓地的场合，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个效果适用过的回合，自己不能把风属性以外的怪兽特殊召唤。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，把自己场上1只名字带有「幻兽机」的怪兽解放才能发动。这张卡的等级上升1星。「幻兽机 暴风雪莺」的效果1回合只能发动1次。
function c31480215.initial_effect(c)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 当自己场上存在衍生物时，此效果适用
	e1:SetCondition(aux.tkfcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 这张卡作为机械族怪兽的同调召唤的素材送去墓地的场合，把1只「幻兽机衍生物」特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31480215,0))  --"特殊召唤衍生物"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,31480215)
	e3:SetCondition(c31480215.spcon)
	e3:SetTarget(c31480215.sptg)
	e3:SetOperation(c31480215.spop)
	c:RegisterEffect(e3)
	-- 把自己场上1只名字带有「幻兽机」的怪兽解放才能发动。这张卡的等级上升1星
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31480215,1))  --"等级上升"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,31480215)
	e4:SetCost(c31480215.lvcost)
	e4:SetOperation(c31480215.lvop)
	c:RegisterEffect(e4)
end
-- 效果适用的条件：此卡在墓地且因同调召唤被作为素材
function c31480215.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsRace(RACE_MACHINE)
end
-- 设置效果处理时将要特殊召唤衍生物和怪兽
function c31480215.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理时将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 发动效果时，使自己不能特殊召唤风属性以外的怪兽，并特殊召唤1只幻兽机衍生物
function c31480215.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个使自己不能特殊召唤风属性以外怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31480215.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
	-- 检查场上是否有足够的空间特殊召唤衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查是否可以特殊召唤幻兽机衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建幻兽机衍生物
		local token=Duel.CreateToken(tp,31480216)
		-- 将幻兽机衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制不能特殊召唤非风属性的怪兽
function c31480215.splimit(e,c,tp,sumtp,sumpos)
	return c:GetAttribute()~=ATTRIBUTE_WIND
end
-- 发动效果时，需要解放1只名字带有「幻兽机」的怪兽作为费用
function c31480215.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有满足条件的怪兽可以解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x101b) end
	-- 选择1只名字带有「幻兽机」的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x101b)
	-- 将选中的怪兽解放作为发动效果的费用
	Duel.Release(g,REASON_COST)
end
-- 发动效果时，使此卡的等级上升1星
function c31480215.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个使此卡等级上升1星的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
