--最果てのゴーティス
-- 效果：
-- 鱼族调整1只以上＋调整以外的怪兽1只以上
-- ①：这张卡的原本攻击力变成除外状态的怪兽数量×500。
-- ②：对方回合，这张卡同调召唤的场合才能发动。场上的卡全部除外。
-- ③：这张卡从怪兽区域除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册卡片的各项效果，包括同调召唤手续、原本攻击力变化、同调召唤成功时除外全场、被除外后特殊召唤以及素材检查效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：鱼族调整1只以上＋调整以外的怪兽1只以上
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsRace,RACE_FISH),aux.NonTuner(nil),nil,s.mfilter,0,99)
	-- ①：这张卡的原本攻击力变成除外状态的怪兽数量×500。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SET_BASE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.atkval)
	c:RegisterEffect(e0)
	-- ②：对方回合，这张卡同调召唤的场合才能发动。场上的卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ③：这张卡从怪兽区域除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。（记录除外时点和状态的辅助效果）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(s.spreg)
	c:RegisterEffect(e2)
	-- ③：这张卡从怪兽区域除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 鱼族调整1只以上＋调整以外的怪兽1只以上（检查同调素材的辅助效果）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)
end
-- 过滤同调素材的辅助函数，允许鱼族调整作为非调整素材，或者过滤非调整怪兽
function s.mfilter(c,syncard)
	return (c:IsRace(RACE_FISH) and c:IsTuner(syncard)) or c:IsNotTuner(syncard)
end
-- 过滤除外状态中表侧表示怪兽的条件函数
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 计算原本攻击力数值的函数，返回除外状态的表侧表示怪兽数量×500
function s.atkval(e,c)
	-- 获取双方除外状态的表侧表示怪兽数量并乘以500
	return Duel.GetMatchingGroupCount(s.filter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*500
end
-- 场上卡片全部除外效果的发动条件函数，要求自身同调召唤成功且当前为对方回合
function s.rmcon(e)
	local c=e:GetHandler()
	-- 检查自身是否是通过同调召唤特殊召唤，且当前回合玩家不是自身的召唤玩家（即对方回合）
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.GetTurnPlayer()~=c:GetSummonPlayer()
end
-- 场上卡片全部除外效果的发动准备与合法性检查函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有可以被除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁处理中的操作信息，表示将除外场上的这些卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 场上卡片全部除外效果的执行函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取双方场上所有可以被除外的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将获取到的场上卡片全部以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 自身被除外时的辅助注册函数，记录被除外的回合数并给自身添加标记
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合数
	local ct=Duel.GetTurnCount()
	e:SetLabel(ct)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 自身特殊召唤效果的发动条件函数，要求在被除外的下个回合的准备阶段，且之前是从怪兽区域被除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前回合数不等于被除外时的回合数（即下个回合以后），且自身带有被除外时注册的标记
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and c:GetFlagEffect(id)>0
		and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 自身特殊召唤效果的发动准备与合法性检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身怪兽区域是否有空位，以及自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息，表示将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 自身特殊召唤效果的执行函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检查同调素材的函数，若使用了2只以上的调整怪兽作为素材，则为自身注册特定的标记效果
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 鱼族调整1只以上＋调整以外的怪兽1只以上（注册多调整同调素材的特定标记）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
