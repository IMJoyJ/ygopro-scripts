--C・ピニー
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·光辉青苔」。
function c29246354.initial_effect(c)
	-- 将卡牌「新空间侠·光辉青苔」（17732278）登记进当前卡的代码列表，表示这张卡的效果文本中记载了该卡名，供相关检索或联动判定使用。
	aux.AddCodeList(c,17732278)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·光辉青苔」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29246354,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c29246354.spcon)
	e1:SetCost(c29246354.spcost)
	e1:SetTarget(c29246354.sptg)
	e1:SetOperation(c29246354.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判断函数：作为起动效果的发动条件，判定当前场上是否存在「新宇宙」这张环境卡。
function c29246354.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上是否有卡号42015635的「新宇宙」存在，若存在则条件成立。
	return Duel.IsEnvironment(42015635)
end
-- 代价函数：将这张卡自身解放作为发动代价；先检查该卡是否可被解放，再实际执行解放。
function c29246354.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价形式解放这张卡自身，将其送入墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤对象筛选条件：卡牌必须是「新空间侠·光辉青苔」（17732278），且能够被特殊召唤。
function c29246354.spfilter(c,e,tp)
	return c:IsCode(17732278) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标检查：判定我方主要怪兽区是否有空位，以及手卡·卡组中是否存在符合特殊召唤条件的「新空间侠·光辉青苔」。
function c29246354.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区可用区域数是否为非负数（由于解放自身可腾出位置，允许当前空位为0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查我方手卡·卡组中是否存在至少1张满足筛选条件的「新空间侠·光辉青苔」。
		and Duel.IsExistingMatchingCard(c29246354.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果处理为从手卡·卡组特殊召唤1只怪兽，以用于相关效果联动检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：在使用者选择后，从手卡·卡组将符合条件的「新空间侠·光辉青苔」特殊召唤到自己场上。
function c29246354.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认我方主要怪兽区有至少1个可用空格，若没有则处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认场上仍有「新宇宙」存在，否则效果处理不适用。
	if not Duel.IsEnvironment(42015635) then return end
	-- 向当前玩家显示“请选择要特殊召唤的卡”的卡片选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1张满足筛选条件的「新空间侠·光辉青苔」。
	local g=Duel.SelectMatchingCard(tp,c29246354.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
