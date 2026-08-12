--スターダスト・イルミネイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「星尘」怪兽送去墓地。自己场上有着「星尘龙」或者有那个卡名记述的同调怪兽存在的场合，也能不送去墓地特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「星尘」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或下降1星。
function c37750912.initial_effect(c)
	-- 记录此卡效果文本上记载着「星尘龙」的卡名
	aux.AddCodeList(c,44508094)
	-- ①：从卡组把1只「星尘」怪兽送去墓地。自己场上有着「星尘龙」或者有那个卡名记述的同调怪兽存在的场合，也能不送去墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37750912)
	e1:SetTarget(c37750912.target)
	e1:SetOperation(c37750912.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「星尘」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37750912,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,37750913)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37750912.lvltg)
	e2:SetOperation(c37750912.lvlop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「星尘」怪兽，可送去墓地或特殊召唤
function c37750912.tgfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa3)
		and (c:IsAbleToGrave() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 过滤函数，用于检测场上是否存在「星尘龙」或带有「星尘龙」卡名记述的同调怪兽
function c37750912.cfilter(c)
	-- 检测场上是否存在「星尘龙」或带有「星尘龙」卡名记述的同调怪兽
	return c:IsFaceup() and (c:IsCode(44508094) or c:IsType(TYPE_SYNCHRO) and aux.IsCodeListed(c,44508094))
end
-- 判断是否满足①效果的发动条件，即场上存在「星尘龙」或同调怪兽且有空场
function c37750912.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测场上是否存在「星尘龙」或同调怪兽
		local check=Duel.IsExistingMatchingCard(c37750912.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 检测场上是否有空位用于特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测卡组中是否存在满足条件的「星尘」怪兽
		return Duel.IsExistingMatchingCard(c37750912.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 处理①效果的发动，根据条件选择将怪兽送去墓地或特殊召唤
function c37750912.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测场上是否存在「星尘龙」或同调怪兽
	local check=Duel.IsExistingMatchingCard(c37750912.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检测场上是否有空位用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择一只满足条件的「星尘」怪兽
	local g=Duel.SelectMatchingCard(tp,c37750912.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否选择特殊召唤，若不能送去墓地则由玩家选择是否特殊召唤
			and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1152)==1) then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于筛选场上正面表示的「星尘」怪兽
function c37750912.lvlfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa3) and c:IsLevelAbove(0)
end
-- 处理②效果的目标选择，选择场上正面表示的「星尘」怪兽
function c37750912.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c37750912.lvlfilter(chkc) end
	-- 检测场上是否存在正面表示的「星尘」怪兽
	if chk==0 then return Duel.IsExistingTarget(c37750912.lvlfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择场上正面表示的「星尘」怪兽作为目标
	local g=Duel.SelectTarget(tp,c37750912.lvlfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理②效果的发动，根据选择决定怪兽等级上升或下降
function c37750912.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local opt=0
		if tc:IsLevel(1) then
			-- 当目标怪兽等级为1时，仅提供等级上升选项
			opt=Duel.SelectOption(tp,aux.Stringid(37750912,1))  --"等级上升"
		else
			-- 当目标怪兽等级大于1时，提供等级上升或下降选项
			opt=Duel.SelectOption(tp,aux.Stringid(37750912,1),aux.Stringid(37750912,2))  --"等级上升/等级下降"
		end
		-- 创建等级变更效果，使目标怪兽等级上升或下降1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if opt==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
