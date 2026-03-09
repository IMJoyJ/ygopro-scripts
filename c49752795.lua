--双天の再来
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「双天」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本等级是4星以下的「双天」怪兽特殊召唤的场合，可以再在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。
function c49752795.initial_effect(c)
	-- 创建效果，设置为发动时点，可以特殊召唤怪兽，具有取对象属性，限制一回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,49752795+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c49752795.target)
	e1:SetOperation(c49752795.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断墓地中的怪兽是否为「双天」族且可以被特殊召唤
function c49752795.filter(c,e,tp)
	return c:IsSetCard(0x14f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数，检查是否有满足条件的墓地怪兽可作为对象
function c49752795.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c49752795.filter(chkc,e,tp) end
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地中是否存在符合条件的「双天」怪兽
		and Duel.IsExistingTarget(c49752795.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一个满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c49752795.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	local tc=g:GetFirst()
	if tc:GetOriginalLevel()<=4 then
		-- 设置操作信息，表示可能再特殊召唤一只衍生物
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	end
end
-- 发动处理函数，执行特殊召唤和可能的衍生物召唤
function c49752795.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽特殊召唤到场上，并判断其等级是否为4星以下
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:GetOriginalLevel()<=4 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤衍生物，并询问是否发动此效果
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) and Duel.SelectYesNo(tp,aux.Stringid(49752795,0)) then  --"是否要特殊召唤衍生物？"
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
			-- 创建一张「双天魂衍生物」卡牌对象
			local token=Duel.CreateToken(tp,49752796)
			-- 将创建的衍生物特殊召唤到场上
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
