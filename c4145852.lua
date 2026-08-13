--十二獣ラム
-- 效果：
-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 羊冲」以外的自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡为对象的对方的陷阱卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
function c4145852.initial_effect(c)
	-- 这张卡被战斗·效果破坏的场合，以「十二兽 羊冲」以外的自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4145852,0))  --"墓地「十二兽」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c4145852.spcon)
	e1:SetTarget(c4145852.sptg)
	e1:SetOperation(c4145852.spop)
	c:RegisterEffect(e1)
	-- 持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡为对象的对方的陷阱卡的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4145852,1))  --"陷阱卡的效果发动无效（十二兽 羊冲）"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c4145852.discon)
	e2:SetCost(c4145852.discost)
	e2:SetTarget(c4145852.distg)
	e2:SetOperation(c4145852.disop)
	c:RegisterEffect(e2)
end
-- 发动条件判断：确认这张卡被破坏的场合其原因包含战斗破坏或效果破坏（r中含有REASON_BATTLE或REASON_EFFECT），即满足①的“被战斗·效果破坏的场合”。
function c4145852.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 特殊召唤对象筛选：从自己墓地选择满足“十二兽”字段、可被特殊召唤、且不是「十二兽 羊冲」自身的怪兽。
function c4145852.spfilter(c,e,tp)
	return c:IsSetCard(0xf1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(4145852)
end
-- 效果发动时的目标处理：先检查自己主要怪兽区有空位且墓地存在符合条件的对象；连锁处理时若指定对象，则验证该对象在自己墓地且满足筛选条件。整体为取自己墓地1只符合条件的「十二兽」怪兽为对象。
function c4145852.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4145852.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己场上必须存在可用的主要怪兽区空格，以保证特殊召唤能够处理。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足spfilter条件（「十二兽」字段、可特殊召唤、不是「十二兽 羊冲」）的怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c4145852.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在选择特殊召唤对象前，向玩家显示“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件且可特殊召唤的「十二兽」怪兽作为效果对象，并建立取对象联系。
	local g=Duel.SelectTarget(tp,c4145852.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次效果处理的操作信息：效果分类为特殊召唤，对象为所选怪兽组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：取出已选择的对象卡，若其仍与效果存在关联，则将其以表侧表示特殊召唤到自己场上（不改变持有者）。
function c4145852.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（唯一的特殊召唤对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区，同时检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②赋予的超量怪兽效果发动条件：本超量怪兽的原本种族为兽战士族、自身未被战斗破坏确定、对方发动了以这张卡为对象的陷阱卡效果、该连锁可以被无效，并且该效果具有取对象标志且对象中包含这张卡。
function c4145852.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方发动的连锁中陷阱卡效果的对象卡片组，用于后续判断该效果是否以本卡为对象。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 确认对方发动的是陷阱卡效果（re为陷阱卡）且该连锁的发动可以被无效。
		and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and tg and tg:IsContains(c)
end
-- 发动代价：发动此效果前，需要从这张超量怪兽身上取除1个超量素材作为代价；先检查是否有素材可取，再实际取除1个素材。
function c4145852.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标阶段：效果发动无条件成立；向对方提示己方发动了此效果，并设置操作信息为无效对方连锁。
function c4145852.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示“已选择发动此效果”，并显示该效果的文字描述，使对方知晓被无效的对象。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本效果处理将使对方发动的那个陷阱卡效果（eg所代表的连锁）发动无效，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理时，直接无效对方发动的那个陷阱卡效果的发动。
function c4145852.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对应连锁的陷阱卡发动无效，完成“那个发动无效”的处理。
	Duel.NegateActivation(ev)
end
