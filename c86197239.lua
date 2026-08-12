--インフェルニティ・ミラージュ
-- 效果：
-- 这张卡不能作从墓地的特殊召唤。自己手卡是0张的场合，把这张卡解放，选择自己墓地存在的2只名字带有「永火」的怪兽才能发动。选择的怪兽在自己场上特殊召唤。
function c86197239.initial_effect(c)
	-- 这张卡不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为始终返回false，即不能特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己手卡是0张的场合，把这张卡解放，选择自己墓地存在的2只名字带有「永火」的怪兽才能发动。选择的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86197239,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c86197239.spcon)
	e2:SetCost(c86197239.spcost)
	e2:SetTarget(c86197239.sptg)
	e2:SetOperation(c86197239.spop)
	c:RegisterEffect(e2)
end
-- 定义发动条件判定函数
function c86197239.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手牌数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义发动代价判定与执行函数
function c86197239.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义过滤条件：属于「永火」系列且可以特殊召唤的怪兽
function c86197239.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的目标选择与合法性检测函数
function c86197239.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c86197239.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在至少2只符合条件的「永火」怪兽
		and Duel.IsExistingTarget(c86197239.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 发送系统提示，要求玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只符合条件的「永火」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86197239.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置特殊召唤2张卡的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 定义效果处理的执行函数
function c86197239.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<sg:GetCount() or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if sg:GetCount()>0 then
		-- 将仍符合条件的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
