--屈強の釣り師
-- 效果：
-- ①：这张卡直接攻击给与对方战斗伤害时，以自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c16632144.initial_effect(c)
	-- ①：这张卡直接攻击给与对方战斗伤害时，以自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16632144,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c16632144.spcon)
	e1:SetTarget(c16632144.sptg)
	e1:SetOperation(c16632144.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判定函数：确认受到战斗伤害的是对方玩家，且本次战斗为这张卡对对方的直接攻击（无攻击对象）。
function c16632144.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 触发条件具体为：ep~=tp（对方受到战斗伤害）且Duel.GetAttackTarget()==nil（攻击目标为空，即直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 特殊召唤对象的过滤函数：判断自己墓地的怪兽是否能够被本效果以表侧守备表示特殊召唤（需满足召唤条件和苏生限制）。
function c16632144.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时的目标选择处理：确认对象卡位于自己墓地且满足特殊召唤条件；检查场地和可用对象；然后选择1只墓地的怪兽作为效果对象。
function c16632144.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16632144.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c16632144.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家弹出选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的满足条件的怪兽中选择1只，将其设定为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c16632144.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的操作信息：宣告将进行特殊召唤，对象为选中的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：取得之前选择的对象，若该对象仍与效果相关，则将其特殊召唤。
function c16632144.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的第一张（也是唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到发动者自己场上（仍会检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
