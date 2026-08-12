--魔轟神ディフ
-- 效果：
-- 名字带有「魔轰神」的怪兽从手卡送去自己墓地时，把自己场上存在的这张卡解放，选择那1只怪兽才能发动。选择怪兽在自己场上特殊召唤。
function c86840720.initial_effect(c)
	-- 名字带有「魔轰神」的怪兽从手卡送去自己墓地时，把自己场上存在的这张卡解放，选择那1只怪兽才能发动。选择怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86840720,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c86840720.spcost)
	e1:SetTarget(c86840720.sptg)
	e1:SetOperation(c86840720.spop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：解放自己场上的这张卡
function c86840720.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足“从手卡送去自己墓地的名字带有「魔轰神」的怪兽，且可以成为效果对象并特殊召唤”条件的卡片
function c86840720.filter(c,e,tp)
	return c:IsSetCard(0x35) and c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的发动检测与对象选择
function c86840720.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c86840720.filter(chkc,e,tp) end
	-- 检查怪兽区域是否有空位（因解放自身，可用格子数大于-1即可），并检查送去墓地的卡中是否存在满足条件的「魔轰神」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and eg:IsExists(c86840720.filter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c86840720.filter,1,1,nil,e,tp)
	-- 将选择的卡片设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置效果处理信息为：特殊召唤该对象卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理：将选择的对象怪兽在自己场上特殊召唤
function c86840720.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
