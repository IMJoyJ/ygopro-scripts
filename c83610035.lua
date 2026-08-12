--セリオンズ“リリー”ボレア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或者植物族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把1张「兽带斗神」魔法·陷阱卡加入手卡。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
local s,id,o=GetID()
-- 初始化此卡的效果：注册①效果（手卡特召并装备墓地怪兽）、②效果（送墓检索魔陷）、③效果（授予装备怪兽②效果）、④效果（装备怪兽攻击力上升700）。
function c83610035.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或者植物族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83610035,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,83610035)
	e1:SetTarget(c83610035.sptg)
	e1:SetOperation(c83610035.spop)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把1张「兽带斗神」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83610035,1))  --"卡组检索（兽带斗神“百合”胃宿二）"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,83610035+o)
	e2:SetCost(c83610035.thcost)
	e2:SetTarget(c83610035.thtg)
	e2:SetOperation(c83610035.thop)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的「兽带斗神」怪兽...得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c83610035.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700...
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c83610035.atkcon)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地中可以作为装备卡装备的「兽带斗神」怪兽或植物族怪兽。
function c83610035.eqfilter(c,tp)
	return (c:IsRace(RACE_PLANT) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①效果的发动准备与合法性检测，确认双方场上有空位，且墓地有合法的装备对象，并选择墓地的对象。
function c83610035.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c83610035.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 检查自己场上是否有可用的怪兽区域和魔法与陷阱区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1只满足装备过滤条件的怪兽。
		and Duel.IsExistingTarget(c83610035.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要装备的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己墓地1只合法的怪兽作为效果的对象。
	local sg=Duel.SelectTarget(tp,c83610035.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息，表示有1张卡将离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置操作信息，表示将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：将这张卡从手卡特殊召唤，并将墓地的目标怪兽作为装备卡装备给这张卡，同时添加装备限制。
function c83610035.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域，且这张卡是否仍与效果相关联。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡以表侧表示特殊召唤，并确认特殊召唤是否成功。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取在发动时选择的墓地目标怪兽。
		local tc=Duel.GetFirstTarget()
		-- 检查目标怪兽是否仍与效果相关联，且自己场上是否有可用的魔法与陷阱区域。
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 将目标怪兽作为装备卡装备给特殊召唤的这张卡。
			Duel.Equip(tp,tc,c,false)
			-- ①：...作为对象的怪兽当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c83610035.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 限制该装备卡只能装备给这张卡（效果的拥有者）。
function c83610035.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动代价处理：从自己的手卡或场上选择1张卡送去墓地。
function c83610035.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己手卡或场上1张可以作为代价送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中可以加入手卡的「兽带斗神」魔法·陷阱卡。
function c83610035.thfilter(c)
	return c:IsSetCard(0x179) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果的发动准备与合法性检测，确认卡组中存在可检索的卡，并设置操作信息。
function c83610035.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可以加入手卡的「兽带斗神」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c83610035.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组选择1张「兽带斗神」魔法·陷阱卡加入手卡，并给对方确认。
function c83610035.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足检索条件的「兽带斗神」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c83610035.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤获得效果的对象：必须是装备了这张卡的「兽带斗神」怪兽。
function c83610035.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 检查攻击力上升效果的适用条件：这张卡必须装备在「兽带斗神」怪兽上。
function c83610035.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
