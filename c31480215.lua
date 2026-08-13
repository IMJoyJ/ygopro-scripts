--幻獣機ウォーブラン
-- 效果：
-- 这张卡作为机械族怪兽的同调召唤的素材送去墓地的场合，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个效果适用过的回合，自己不能把风属性以外的怪兽特殊召唤。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，把自己场上1只名字带有「幻兽机」的怪兽解放才能发动。这张卡的等级上升1星。「幻兽机 暴风雪莺」的效果1回合只能发动1次。
function c31480215.initial_effect(c)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置该抗性效果的适用条件：自己场上存在衍生物（Token）时效果适用。
	e1:SetCondition(aux.tkfcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 这张卡作为机械族怪兽的同调召唤的素材送去墓地的场合，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个效果适用过的回合，自己不能把风属性以外的怪兽特殊召唤。
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
	-- 此外，把自己场上1只名字带有「幻兽机」的怪兽解放才能发动。这张卡的等级上升1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31480215,1))  --"等级上升"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,31480215)
	e4:SetCost(c31480215.lvcost)
	e4:SetOperation(c31480215.lvop)
	c:RegisterEffect(e4)
end
-- 特殊召唤衍生物效果的发动条件判定：确认这张卡作为机械族怪兽的同调召唤素材被送去墓地（位于墓地且reason为同调召唤，素材对象即同调召唤的怪兽为机械族）。
function c31480215.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsRace(RACE_MACHINE)
end
-- 特殊召唤衍生物效果的发动目标处理：不取对象，直接返回可发动，并写入本次连锁包含衍生物生成与特殊召唤的操作信息。
function c31480215.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁涉及衍生物（CATEGORY_TOKEN）的生成，预计生成1只，不指定对象/玩家/位置。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本连锁涉及特殊召唤（CATEGORY_SPECIAL_SUMMON），预计特殊召唤1只怪兽，不指定对象/玩家/位置。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物效果的处理：先给当前玩家注册“本回合不能特殊召唤风属性以外怪兽”的自肃效果；若主怪兽区有空位且玩家允许特殊召唤「幻兽机衍生物」，则生成衍生物并表侧特殊召唤到己方场上。
function c31480215.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 把1只「幻兽机衍生物」特殊召唤。这个效果适用过的回合，自己不能把风属性以外的怪兽特殊召唤。此外，把自己场上1只名字带有「幻兽机」的怪兽解放才能发动。这张卡的等级上升1星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31480215.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果（不能特殊召唤风属性以外怪兽）注册给当前玩家tp，持续到本回合结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 检查当前玩家tp的主要怪兽区是否有空位；若无空位则无法特殊召唤衍生物，直接结束本次效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判定当前玩家tp能否特殊召唤「幻兽机衍生物」（卡号31533705，系列字段0x101b，衍生物，攻/守0，等级3，机械族，风属性，表侧表示）。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 在玩家tp的场上创建1只「幻兽机衍生物」（Token，卡号31480216），返回该Token对象。
		local token=Duel.CreateToken(tp,31480216)
		-- 将创建的「幻兽机衍生物」以表侧攻击/守备表示特殊召唤到玩家tp的场上（不检查召唤条件/苏生限制）。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 自肃效果的过滤器：若怪兽属性不是风属性，则返回true，即禁止其特殊召唤。
function c31480215.splimit(e,c,tp,sumtp,sumpos)
	return c:GetAttribute()~=ATTRIBUTE_WIND
end
-- 等级上升效果的COST处理：检查并选择自己场上1只除自身外名字带有「幻兽机」的怪兽解放作为发动代价；若无法满足则不可发动。
function c31480215.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在COST合法性检查阶段，判定是否存在至少1只除自身外、名字带有「幻兽机」（0x101b）的怪兽可以作为解放代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x101b) end
	-- 让玩家从自己场上选择1只除自身外、名字带有「幻兽机」（0x101b）的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x101b)
	-- 将选择的怪兽解放，作为等级上升效果发动的COST（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 等级上升效果的处理：若这张卡仍表侧存在于场上且与效果相关，则为它临时附加“等级上升1星”的效果，该效果在离场/重置等标准时机失效。
function c31480215.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
