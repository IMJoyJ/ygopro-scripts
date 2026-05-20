--伏魔殿－悪魔の迷宮－
-- 效果：
-- 只要这张卡在场上存在，自己场上的恶魔族怪兽的攻击力上升500。此外，选择自己场上1只名字带有「恶魔」的怪兽才能发动。选出选择的怪兽以外的自己场上1只恶魔族怪兽从游戏中除外，从自己的手卡·卡组·墓地选和选择的怪兽相同等级的1只名字带有「恶魔」的怪兽特殊召唤。「伏魔殿-恶魔的迷宫-」的这个效果1回合只能使用1次。
function c63883999.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上的恶魔族怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 限制攻击力上升效果的适用对象为自己场上的恶魔族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FIEND))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 此外，选择自己场上1只名字带有「恶魔」的怪兽才能发动。选出选择的怪兽以外的自己场上1只恶魔族怪兽从游戏中除外，从自己的手卡·卡组·墓地选和选择的怪兽相同等级的1只名字带有「恶魔」的怪兽特殊召唤。「伏魔殿-恶魔的迷宫-」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63883999,0))  --"是否要选择对方场上表侧表示存在的1张卡破坏？"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,63883999)
	e3:SetTarget(c63883999.target)
	e3:SetOperation(c63883999.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：用于筛选自己场上表侧表示且有等级的「恶魔」怪兽，要求场上有其他可除外的恶魔族怪兽，且手卡/卡组/墓地有同等级可特召的「恶魔」怪兽
function c63883999.filter(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsFaceup() and c:IsSetCard(0x45)
		-- 检查自己场上是否存在除选择的怪兽以外的、可以除外的恶魔族怪兽
		and Duel.IsExistingMatchingCard(c63883999.rfilter,tp,LOCATION_MZONE,0,1,c)
		-- 检查自己的手卡、卡组、墓地是否存在可以特殊召唤的、与选择怪兽相同等级的「恶魔」怪兽
		and Duel.IsExistingMatchingCard(c63883999.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 过滤函数：筛选自己场上表侧表示、可以除外的恶魔族怪兽
function c63883999.rfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAbleToRemove()
end
-- 过滤函数：筛选手卡/卡组/墓地中与指定等级相同、可以特殊召唤的「恶魔」怪兽
function c63883999.spfilter(c,lv,e,tp)
	return c:IsSetCard(0x45) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测与目标选择处理
function c63883999.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63883999.filter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上的怪兽区域是否有空位（因为需要除外1只怪兽并特召1只，所以空位要求大于等于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己场上是否存在满足条件的、可作为效果对象的「恶魔」怪兽
		and Duel.IsExistingTarget(c63883999.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的「恶魔」怪兽作为效果的对象
	Duel.SelectTarget(tp,c63883999.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：从手卡、卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
	-- 设置效果处理信息：从场上除外1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
-- 效果处理的执行函数
function c63883999.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择作为效果对象的怪兽以外的、自己场上1只恶魔族怪兽
		local rg=Duel.SelectMatchingCard(tp,c63883999.rfilter,tp,LOCATION_MZONE,0,1,1,tc)
		-- 如果成功除外了选中的恶魔族怪兽
		if rg:GetCount()>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
			-- 提示玩家选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡、卡组、墓地中选择1只与效果对象相同等级的「恶魔」怪兽（适用王家长眠之谷的过滤）
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c63883999.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tc:GetLevel(),e,tp)
			-- 将选择的「恶魔」怪兽特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
