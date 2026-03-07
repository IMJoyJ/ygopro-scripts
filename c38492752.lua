--ラヴァル・キャノン
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以选择从游戏中除外的1只自己的名字带有「熔岩」的怪兽特殊召唤。
function c38492752.initial_effect(c)
	-- 这张卡通常召唤成功时，可以选择从游戏中除外的1只自己的名字带有「熔岩」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38492752,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c38492752.sptg)
	e1:SetOperation(c38492752.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查目标怪兽是否为名字带有「熔岩」的怪兽且可以特殊召唤
function c38492752.filter(c,e,tp)
	return c:IsSetCard(0x39) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设定效果的发动条件，判断是否满足特殊召唤的条件
function c38492752.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c38492752.filter(chkc,e,tp) end
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家除外区是否有符合条件的「熔岩」怪兽
		and Duel.IsExistingTarget(c38492752.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的1只除外怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c38492752.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，将选中的怪兽特殊召唤
function c38492752.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果所选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
