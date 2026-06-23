--水晶機巧－グリオンガンド
-- 效果：
-- 调整2只以上＋调整以外的怪兽1只
-- ①：这张卡同调召唤成功的场合，以最多有那些作为同调素材的怪兽数量的对方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。
-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c13455674.initial_effect(c)
	-- 添加同调召唤手续，要求2只以上调整加上1只调整以外的怪兽作为同调素材
	aux.AddSynchroMixProcedure(c,aux.NonTuner(nil),nil,nil,aux.Tuner(nil),2,99)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合，以最多有那些作为同调素材的怪兽数量的对方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13455674,0))  --"对方怪兽除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c13455674.rmcon)
	e2:SetTarget(c13455674.rmtg)
	e2:SetOperation(c13455674.rmop)
	c:RegisterEffect(e2)
	-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13455674,1))  --"除外的怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c13455674.spcon)
	e3:SetTarget(c13455674.sptg)
	e3:SetOperation(c13455674.spop)
	c:RegisterEffect(e3)
	-- 不能被无效且不能被复制的效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- 效果条件：确认此卡是否为同调召唤成功
function c13455674.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 除外怪兽的过滤条件：必须是怪兽且可以除外
function c13455674.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果目标选择：根据同调素材数量选择对方场上或墓地的怪兽
function c13455674.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetHandler():GetMaterialCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(1-tp) and c13455674.rmfilter(chkc) end
	-- 检查阶段：确认是否有满足条件的怪兽可选
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c13455674.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 优先从场上选择目标怪兽，不足时再从墓地选择
	local g=aux.SelectTargetFromFieldFirst(tp,c13455674.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,ct,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 设置操作信息：将选中的怪兽除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
	else
		-- 设置操作信息：将选中的怪兽除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	end
end
-- 效果处理：将目标怪兽除外
function c13455674.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的卡片除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果条件：确认此卡是否为同调召唤且被战斗或效果破坏
function c13455674.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤怪兽的过滤条件：必须是可特殊召唤的怪兽
function c13455674.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标选择：选择一只除外的怪兽作为特殊召唤对象
function c13455674.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c13455674.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 检查阶段：确认是否有满足条件的怪兽可选
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查阶段：确认是否有满足条件的怪兽可选
		and Duel.IsExistingTarget(c13455674.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择一只除外的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c13455674.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息：将选中的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将目标怪兽特殊召唤
function c13455674.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
