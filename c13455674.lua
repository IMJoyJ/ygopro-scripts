--水晶機巧－グリオンガンド
-- 效果：
-- 调整2只以上＋调整以外的怪兽1只
-- ①：这张卡同调召唤成功的场合，以最多有那些作为同调素材的怪兽数量的对方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。
-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c13455674.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整以外的怪兽1只，加上调整2只以上（合计3～99只，实际受可用怪兽数限制），满足水晶机巧-中枢大蛇的召唤素材条件。
	aux.AddSynchroMixProcedure(c,aux.NonTuner(nil),nil,nil,aux.Tuner(nil),2,99)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以最多有那些作为同调素材的怪兽数量的对方的场上·墓地的怪兽为对象才能发动。那些怪兽除外。
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
	-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以这张卡以外的自己或对方的除外状态的1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
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
	-- 登记一个不可无效、不可复制的效果外文本标记（卡号21142671对应的内部效果），用于让这张卡正确获得同调怪兽的苏生限制等原始设定。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- ①效果发动条件：这张卡是作为同调召唤成功而触发，即确认这张卡是以同调方式特殊召唤成功。
function c13455674.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的筛选条件：对方的怪兽且当前能够被除外。
function c13455674.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ①效果的发动时点：以同调素材数量为最多可选数量，从对方场上·墓地的怪兽中选择对象并设置除外相关的操作信息；优先从场上选，场上不足时再从墓地补足。
function c13455674.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=e:GetHandler():GetMaterialCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(1-tp) and c13455674.rmfilter(chkc) end
	-- 发动合法性检查：同调素材数大于0，且对方场上·墓地存在至少1只可被除外且能成为对象的怪兽。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c13455674.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 使用辅助选择函数，优先从对方场上选择满足条件的怪兽，若场上可用目标不足最小数量则从对方墓地补选，最多选择同调素材数量的怪兽。
	local g=aux.SelectTargetFromFieldFirst(tp,c13455674.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,ct,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 由于选择的目标中存在墓地怪兽，设置操作信息：这些墓地怪兽将被除外。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
	else
		-- 选择的目标中没有墓地怪兽（全部在场上），设置操作信息：将这些场上怪兽除外。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	end
end
-- ①效果处理：取回连锁上登记的对象卡，过滤出仍与该效果有联系的卡，将它们全部以表侧表示除外。
function c13455674.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得效果发动时选择的全部对象卡，并过滤出仍然与效果e保持关联的卡（防止对象卡失效或离场导致无法处理）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将筛选出的对象怪兽以表侧表示除外，除外原因记为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡被破坏时，确认它在被破坏前位于怪兽区域，并且这张卡是以同调召唤方式出场，破坏原因是战斗或效果。
function c13455674.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- ②效果的筛选条件：除外状态的表侧表示怪兽，并且可以被当前效果特殊召唤。
function c13455674.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时点：从除外状态选择这张卡以外的1只表侧表示且可特殊召唤的怪兽作为对象，同时确认自己场上有可用的怪兽区域。
function c13455674.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c13455674.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 发动合法性检查：自己场上有至少1个可用的主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且除外区存在1张除这张卡本身以外、能被特殊召唤且能成为对象的表侧表示怪兽。
		and Duel.IsExistingTarget(c13455674.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,e:GetHandler(),e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己和对方除外区的表侧表示怪兽中选择1张（不能选发动效果的这张卡自身）作为特殊召唤的对象。
	local g=Duel.SelectTarget(tp,c13455674.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息：本次效果将对选中的1张卡进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取出对象卡，若它仍与该效果有联系，则将其在持有者·自己场上表侧表示特殊召唤。
function c13455674.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的场上，以效果发动的玩家为控制者。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
