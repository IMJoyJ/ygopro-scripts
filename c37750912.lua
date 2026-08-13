--スターダスト・イルミネイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「星尘」怪兽送去墓地。自己场上有着「星尘龙」或者有那个卡名记述的同调怪兽存在的场合，也能不送去墓地特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「星尘」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或下降1星。
function c37750912.initial_effect(c)
	-- 登记这张卡的效果文本中记载的卡号44508094（星尘龙），使后续可用aux.IsCodeListed检测其他卡是否记述了星尘龙。
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
	-- 设置②效果的发动代价：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37750912.lvltg)
	e2:SetOperation(c37750912.lvlop)
	c:RegisterEffect(e2)
end
-- 定义①效果检索/处理对象的过滤条件：必须是「星尘」系列怪兽，且可以送去墓地，或在满足特殊召唤条件时可以被特殊召唤。
function c37750912.tgfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa3)
		and (c:IsAbleToGrave() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 定义检查自己场上是否存在「星尘龙」或记述了星尘龙卡名的同调怪兽的过滤函数。
function c37750912.cfilter(c)
	-- 判断怪兽为表侧表示，且其卡名为星尘龙（44508094），或是表侧表示的同调怪兽且其效果文本中记述了星尘龙。
	return c:IsFaceup() and (c:IsCode(44508094) or c:IsType(TYPE_SYNCHRO) and aux.IsCodeListed(c,44508094))
end
-- ①效果的发动条件：若自己场上存在「星尘龙」或记述星尘龙的同调怪兽且有可用怪兽区域，则检查卡组中是否有可选的「星尘」怪兽；否则也需存在至少1只可以送去墓地的「星尘」怪兽。
function c37750912.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在至少1只满足cfilter的怪兽（星尘龙或记述星尘龙的同调怪兽）。
		local check=Duel.IsExistingMatchingCard(c37750912.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 追加确认自己主要怪兽区域存在可用的空格，用于判断能否选择特殊召唤的路线。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足tgfilter条件的「星尘」怪兽，存在才能发动①效果。
		return Duel.IsExistingMatchingCard(c37750912.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- ①效果处理：从卡组选择1只「星尘」怪兽，根据场上条件和玩家选择将其特殊召唤或送去墓地。
function c37750912.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否存在满足cfilter的怪兽。
	local check=Duel.IsExistingMatchingCard(c37750912.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认仍有可用的主要怪兽区域，以允许特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 显示'请选择要操作的卡'的提示信息，用于后续卡组选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张满足tgfilter条件的「星尘」怪兽（若允许特殊召唤则包含可特召的卡）。
	local g=Duel.SelectMatchingCard(tp,c37750912.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 当选择的卡可以送去墓地且场上满足特殊召唤条件时，弹出选项让玩家选择'送去墓地'或'特殊召唤'；只有选择特殊召唤且该卡能够特殊召唤时才进行特殊召唤，否则送去墓地。
			and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1152)==1) then
			-- 将选择的「星尘」怪兽以表侧攻击表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选择的「星尘」怪兽从卡组送入墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 定义②效果可取对象的过滤条件：自己场上的表侧表示且属于「星尘」系列的怪兽（等级至少为1）。
function c37750912.lvlfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa3) and c:IsLevelAbove(0)
end
-- ②效果的发动条件和取对象处理：选择自己场上1只表侧表示的「星尘」怪兽作为对象。
function c37750912.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c37750912.lvlfilter(chkc) end
	-- 检查自己场上是否存在至少1只满足lvlfilter条件的「星尘」怪兽，若存在则②效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c37750912.lvlfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示'请选择要操作的卡'的提示信息，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择自己场上1只表侧表示的「星尘」怪兽，并将其登记为这张卡发动时的效果对象。
	local g=Duel.SelectTarget(tp,c37750912.lvlfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：令对象怪兽的等级上升或下降1星，直到回合结束时适用。
function c37750912.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local opt=0
		if tc:IsLevel(1) then
			-- 若对象等级为1，不能下降，因此只提供'等级上升'选项并选择之。
			opt=Duel.SelectOption(tp,aux.Stringid(37750912,1))  --"等级上升"
		else
			-- 若对象等级大于1，让玩家选择'等级上升'或'等级下降'。
			opt=Duel.SelectOption(tp,aux.Stringid(37750912,1),aux.Stringid(37750912,2))  --"等级上升/等级下降"
		end
		-- 那只怪兽的等级直到回合结束时上升或下降1星。
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
