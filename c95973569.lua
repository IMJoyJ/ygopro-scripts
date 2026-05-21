--TG グレイヴ・ブラスター
-- 效果：
-- 同调怪兽调整＋调整以外的同调怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：自己·对方回合，以从额外卡组特殊召唤的场上1只怪兽为对象才能发动（这个效果在1回合中可以使用最多有作为这张卡的同调素材的除调整以外的同调怪兽数量的次数）。那只怪兽除外。
-- ②：1回合1次，怪兽被表侧除外的场合，以那之内的1只为对象才能发动。那只怪兽无视召唤条件在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册同调召唤手续、特殊召唤限制、除外效果、素材检查以及被除外时的特殊召唤效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：同调怪兽调整＋调整以外的同调怪兽2只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),aux.NonTuner(Card.IsType,TYPE_SYNCHRO),2)
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 限制该卡只能通过同调召唤的方式进行特殊召唤
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合，以从额外卡组特殊召唤的场上1只怪兽为对象才能发动（这个效果在1回合中可以使用最多有作为这张卡的同调素材的除调整以外的同调怪兽数量的次数）。那只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- （这个效果在1回合中可以使用最多有作为这张卡的同调素材的除调整以外的同调怪兽数量的次数）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetLabelObject(e2)
	e3:SetValue(s.matchk)
	c:RegisterEffect(e3)
	-- 注册一个合并延迟事件，用于监听怪兽被除外的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_REMOVE)
	-- ②：1回合1次，怪兽被表侧除外的场合，以那之内的1只为对象才能发动。那只怪兽无视召唤条件在自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(custom_code)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：自身必须是同调召唤的状态
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤从额外卡组特殊召唤且可以被除外的怪兽
function s.filter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToRemove()
end
-- 效果①的发动准备：检查场上是否存在符合条件的怪兽，并将其设为效果对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查场上是否存在至少1只从额外卡组特殊召唤且可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择要除外卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果将除外选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的处理：将作为对象的怪兽表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①锁定的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽在效果处理时仍合法，则将其表侧表示除外
	if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
-- 检查同调素材，根据作为同调素材的非调整同调怪兽的数量，动态设置效果①在1回合中可以使用的最大次数
function s.matchk(e,c)
	local ef=e:GetLabelObject()
	local ct=c:GetMaterial():FilterCount(Card.IsType,nil,TYPE_SYNCHRO)-1
	if ct<0 then ct=0 end
	ef:SetCountLimit(ct)
end
-- 过滤被表侧除外、可以成为效果对象且可以无视召唤条件特殊召唤的怪兽
function s.sfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动准备：检查是否有符合条件的被除外怪兽，并将其设为特殊召唤的对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.sfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) end
	-- 检查自己场上是否有空余的怪兽区域，且本次被除外的怪兽中是否存在符合特殊召唤条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	-- 向玩家发送选择要特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将玩家选择的被除外怪兽设置为效果对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理信息，表示该效果将特殊召唤选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 效果②的处理：将作为对象的怪兽无视召唤条件在自己场上特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②锁定的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽在效果处理时仍合法，则无视召唤条件将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP) end
end
