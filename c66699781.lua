--カオス・ミラージュ・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以除外的1只自己或者对方的光·暗属性怪兽为对象才能发动。那只怪兽效果无效在自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合，以最多有作为那次同调召唤的素材的除这张卡以外的怪兽数量的对方场上的卡为对象才能发动。那些卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（起动效果，特殊召唤除外的光/暗属性怪兽）和②效果（作为同调素材送去墓地时，除外对方场上的卡）。
function s.initial_effect(c)
	-- ①：以除外的1只自己或者对方的光·暗属性怪兽为对象才能发动。那只怪兽效果无效在自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，以最多有作为那次同调召唤的素材的除这张卡以外的怪兽数量的对方场上的卡为对象才能发动。那些卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤除外区中表侧表示、光或暗属性、且可以被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检测（包括对象判定和空位判定）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定双方除外区是否存在至少1只满足条件的可选择为对象的光·暗属性怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只满足条件的光·暗属性怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息，表明此效果包含特殊召唤该对象的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的执行函数，将对象怪兽效果无效并特殊召唤，并适用“直到回合结束时自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为特殊召唤对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关联，则尝试将其以表侧表示特殊召唤到自己场上（分步处理）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 那只怪兽效果无效在自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。②：这张卡作为同调素材送去墓地的场合，以最多有作为那次同调召唤的素材的除这张卡以外的怪兽数量的对方场上的卡为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤非光·暗属性同调怪兽的限制效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能从额外卡组特殊召唤，除非是光属性或暗属性的同调怪兽。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end
-- ②效果的发动条件判定，即这张卡作为同调素材送去墓地的场合。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ②效果的发动准备与合法性检测，计算除这张卡以外的同调素材数量，并选择对应数量的对方场上的卡作为对象。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取本次同调召唤的素材中，除这张卡以外的怪兽数量。
	local mgc=e:GetHandler():GetReasonCard():GetMaterial():FilterCount(aux.TRUE,e:GetHandler())
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() and chkc:IsControler(1-tp) end
	-- 判定其他素材数量是否大于0，且对方场上是否存在至少1张可以被除外的卡。
	if chk==0 then return mgc>0 and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择最多有其他素材数量的对方场上的卡作为除外对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,mgc,nil)
	-- 设置连锁处理中的操作信息，表明此效果包含除外所选卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- ②效果的执行函数，将选择的对方场上的卡除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择且当前仍与效果相关联的对象卡片。
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将这些对象卡片以表侧表示除外。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
