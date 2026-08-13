--魅惑の宮殿
-- 效果：
-- 这个卡名的③的效果1回合可以使用最多3次。
-- ①：自己场上的魔法师族怪兽的攻击力·守备力上升500。
-- ②：自己场上的「魅惑的女王」效果怪兽得到以下效果。
-- ●把用自身的效果把卡装备的这张卡送去墓地才能发动。从手卡·卡组把1只攻击力1500以下的魔法师族怪兽特殊召唤。
-- ③：把1张手卡送去墓地才能发动。从卡组选1只「魅惑的女王」怪兽加入手卡或在对方场上特殊召唤。
local s,id,o=GetID()
-- 注册本卡的以下效果：e1为魔陷/场地卡可发动；e2/e3使我方魔法师族怪兽攻击力·守备力各自上升500；e5将e4的特殊召唤效果授予我方场上的「魅惑的女王」效果怪兽；e6注册③效果，并从卡组检索/特殊召唤「魅惑的女王」怪兽，限制1回合最多3次。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的魔法师族怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选出自己场上的魔法师族怪兽作为攻击力上升效果的对象。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ●把用自身的效果把卡装备的这张卡送去墓地才能发动。从手卡·卡组把1只攻击力1500以下的魔法师族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"特殊召唤（魅惑的宫殿）"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	-- ②：自己场上的「魅惑的女王」效果怪兽得到以下效果。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 这个卡名的③的效果1回合可以使用最多3次。③：把1张手卡送去墓地才能发动。从卡组选1只「魅惑的女王」怪兽加入手卡或在对方场上特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))  --"选卡组「魅惑的女王」怪兽"
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(3,id)
	e6:SetCost(s.thcost)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
-- 辅助过滤函数：判断卡片是否带有指定编号的FlagEffect标记，用于识别由『魅惑的女王』自身效果变成的装备卡；本脚本中未实际调用。
function s.costfilter(c,code)
	return c:GetFlagEffect(code)~=0
end
-- 作为②●效果的发动代价，将这只正用自身效果装备着卡的『魅惑的女王』怪兽自身送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检测：确认该怪兽可以作为cost送去墓地，并且它当前确实用自身效果装备了卡（aux.IsSelfEquip检查FLAG_ID_ALLURE_QUEEN标记）。
	if chk==0 then return c:IsAbleToGraveAsCost() and aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) end
	-- 将这只『魅惑的女王』怪兽从场上实际送去墓地，作为特殊召唤效果的代价。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 定义可特殊召唤的怪兽条件：攻击力1500以下、魔法师族，且能够被玩家tp特殊召唤（检查召唤条件与苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件检测：确认自己场上有足够怪兽区（该怪兽送墓后空出1格），并且在手牌·卡组存在至少1只符合条件的可特殊召唤的魔法师族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 计算该『魅惑的女王』怪兽离开自己场上后空出的怪兽区数量，并确认大于0。
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		-- 检索手卡·卡组，确认是否存在至少1只攻击力1500以下、魔法师族且可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,e:GetHandler():GetCode()) end
	-- 向对方玩家提示自己发动了该特殊召唤效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次连锁的操作信息为“从手卡·卡组特殊召唤1只怪兽”，供其他卡正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②●效果处理：若自己场上仍有怪兽区，则从手卡·卡组选择1只符合条件的魔法师族怪兽，正面表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次确认自己场上存在可用的怪兽区。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组中选择1张满足spfilter条件的魔法师族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽正面攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 判断哪些怪兽能获得②授予的特召效果：自己场上的「魅惑的女王」效果怪兽（SetCard 0x3且为效果怪兽）。
function s.eftg(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x3)
end
-- ③效果的代价：丢弃1张手卡；先检查手牌中有可丢弃的卡，再选择并送入墓地。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手牌中存在至少1张可以送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示，要求选择要丢弃的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡中选择1张要作为代价丢弃的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手卡送入墓地，支付③效果的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选卡组中可作为③效果对象的『魅惑的女王』怪兽：必须是SetCard 0x3的怪兽，且要么能加入手卡，要么能特殊召唤到对方场上（对方场上有空位且可特召）。
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x3) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取对方场上当前的怪兽区空格数，用于判断是否能特殊召唤到对方场上。
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- ③效果的目标检测：确认卡组存在满足thfilter条件的『魅惑的女王』怪兽。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测：卡组中有满足检索或特殊召唤条件的『魅惑的女王』怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ③效果处理：从卡组选1只『魅惑的女王』怪兽；若该卡能加入手卡且（不能特召到对方场上/对方无空位/玩家选择加入手卡）则加入手卡并展示给对方，否则正面表示特殊召唤到对方场上。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择操作卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1只符合条件的『魅惑的女王』怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 重新获取对方场上可用怪兽区数量，用于决定处理分支。
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断处理分支：若该卡能加入手卡，并且（不能特召到对方场上、对方场上无空位、或玩家选择了“加入手卡”选项），则执行加入手卡；否则执行特殊召唤到对方场上。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将这张『魅惑的女王』怪兽加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的『魅惑的女王』怪兽正面表示特殊召唤到对方场上。
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
