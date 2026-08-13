--騎士魔防陣
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1张表侧表示的怪兽卡为对象才能发动。那张卡除外。下个回合的准备阶段，这个效果除外的怪兽在持有者场上特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「百夫长骑士」同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力下降1500。
local s,id,o=GetID()
-- 初始化卡片效果：创建并注册①效果（场上表侧怪兽除外，下个准备阶段特殊召唤）和②效果（墓地除外自身、特殊召唤「百夫长骑士」同调怪兽并下降攻击力），两个效果共用1回合1次使用次数。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以场上1张表侧表示的怪兽卡为对象才能发动。那张卡除外。下个回合的准备阶段，这个效果除外的怪兽在持有者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「百夫长骑士」同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力下降1500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	-- 设置②效果的发动代价：将墓地的这张卡除外（自身除外作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的对象筛选条件：表侧表示、原本类型为怪兽（怪兽卡），且能够被除外。
function s.filter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsAbleToRemove()
end
-- ①效果发动时的目标选择与合法性判定：检查场上是否存在符合条件的对象，提示玩家选择1张表侧表示怪兽并将其设为对象，同时登记‘除外’的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	-- 发动合法性检查：双方场上是否存在至少1张满足s.filter的卡可作为对象（取对象）。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方场上选择1张满足条件的表侧表示怪兽作为效果对象，并关联到当前连锁。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本连锁的处理信息：将对象卡除外（CATEGORY_REMOVE），供后续时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理①效果：取出对象卡；若对象已不关联则直接终止；否则将对象以表侧表示除外，若除外数量<1或对象不在除外区也终止，否则继续后续处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果对象卡（第一目标）。
	local tc=Duel.GetFirstTarget()
	-- 判断条件：对象仍与效果关联时才将其表侧除外；若对象不关联，或除外不成功，则效果终止。
	if not tc:IsRelateToEffect(e) or Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)<1
		or not tc:IsLocation(LOCATION_REMOVED) then return end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	-- 下个回合的准备阶段，这个效果除外的怪兽在持有者场上特殊召唤。②：把墓地的这张卡除外，以自己墓地1只「百夫长骑士」同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	-- 将当前回合数记录到效果的Label中，用于判断‘下个回合’（当前回合+1）的准备阶段。
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetLabelObject(tc)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	-- 将延迟特殊召唤的持续效果注册到决斗中（由tp方控制），使其在准备阶段被检测触发。
	Duel.RegisterEffect(e1,tp)
end
-- 定义延迟特殊召唤的触发条件：当前回合数为记录回合数+1（即下个准备阶段），且对象卡仍带有本次除外标记时返回true。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 检查是否满足‘下个回合的准备阶段’且目标怪兽仍带有标记，两者同时满足才触发特殊召唤。
	return Duel.GetTurnCount()==e:GetLabel()+1 and tc:GetFlagEffect(id)>0
end
-- 定义延迟特殊召唤的处理：取出被除外的对象怪兽，将其特殊召唤到持有者场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将对象怪兽以表侧表示特殊召唤到其持有者场上（不检查召唤条件/苏生限制，不占用通召）。
	Duel.SpecialSummon(tc,0,tp,tc:GetOwner(),false,false,POS_FACEUP)
end
-- ②效果的对象筛选：自己墓地中满足「百夫长骑士」字段（0x1a2）、为同调怪兽且可被当前效果特殊召唤的卡。
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的目标选择：检查主怪兽区空位和墓地有无符合条件的对象；若有则进入对象选择；连锁时chkc用于校验对象合法性。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	-- 发动合法性检查：自己主要怪兽区是否存在空位（用于后续特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足s.sfilter的「百夫长骑士」同调怪兽可作为对象。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示‘请选择要特殊召唤的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「百夫长骑士」同调怪兽作为效果对象，并关联到当前连锁。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的处理信息：将对象怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取出对象；若对象仍与效果关联，则将其特殊召唤，成功则给那只怪兽附加攻击力下降1500的效果；最后完成特殊召唤步骤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象仍与效果关联，并尝试将其以表侧表示特殊召唤；若成功则继续执行攻击力下降效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力下降1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1500)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤处理，结束SpecialSummonStep过程（与SpecialSummonStep配对使用）。
	Duel.SpecialSummonComplete()
end
