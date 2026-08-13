--セリオンズ“エンプレス”アラシア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或者爬虫类族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：丢弃1张手卡，以自己的魔法与陷阱区域1张「兽带斗神」怪兽卡为对象才能发动。那张卡特殊召唤。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
function c48806195.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或者爬虫类族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48806195,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,48806195)
	e1:SetTarget(c48806195.sptg1)
	e1:SetOperation(c48806195.spop1)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡，以自己的魔法与陷阱区域1张「兽带斗神」怪兽卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48806195,1))  --"魔陷区怪兽卡特殊召唤（兽带斗神“女帝”阿拉西亚星）"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,48806196)
	e2:SetCost(c48806195.spcost2)
	e2:SetTarget(c48806195.sptg2)
	e2:SetOperation(c48806195.spop2)
	c:RegisterEffect(e2)
	-- 得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c48806195.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 有这张卡装备的「兽带斗神」怪兽攻击力上升700
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c48806195.atkcon)
	c:RegisterEffect(e4)
end
-- 筛选条件：对象必须是爬虫类族或卡名含有「兽带斗神」的怪兽，且场上不能有同名卡。
function c48806195.eqfilter(c,tp)
	return (c:IsRace(RACE_REPTILE) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①效果的发动条件和对象选择：自身在手牌可特殊召唤、场上两区域有空位、墓地存在满足条件的对象时，选择1只符合条件的墓地怪兽为对象。
function c48806195.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c48806195.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 检查自己的主要怪兽区和魔法与陷阱区域是否有可用空格，确保能特殊召唤手牌的这张卡并装备墓地怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在1只符合条件的「兽带斗神」怪兽或爬虫类族怪兽可作为对象。
		and Duel.IsExistingTarget(c48806195.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向操作者显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己墓地选择1只符合条件的怪兽作为效果对象。
	local sg=Duel.SelectTarget(tp,c48806195.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：选中的对象怪兽将离开墓地（用于王家长眠之谷等连锁判断）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置操作信息：这张卡将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：先将这张卡从手卡特殊召唤，成功后再将对象怪兽装备给这张卡，并给对象加上只能装备给此卡的限制。
function c48806195.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己主要怪兽区有空位，且这张卡仍与效果关联（没有离场或失效）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡从手卡以表侧攻击表示特殊召唤，若成功则继续后续装备处理。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得发动时选择的墓地对象怪兽。
		local tc=Duel.GetFirstTarget()
		-- 确认对象怪兽仍与效果关联且自己魔陷区有空位，满足条件才进行装备。
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 将对象怪兽作为装备卡装备给这张卡，保持其当前表示形式。
			Duel.Equip(tp,tc,c,false)
			-- 作为对象的怪兽当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c48806195.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备限制：该装备卡只能装备给效果持有者（即这张卡）。
function c48806195.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动代价：从手卡丢弃1张卡。
function c48806195.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡选择1张卡丢弃作为发动代价（丢弃原因记为代价+丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：对象是自己魔陷区表侧表示且卡名含有「兽带斗神」的怪兽，并且可以被特殊召唤。
function c48806195.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x179) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件和对象选择：自己主要怪兽区有空位，且魔陷区存在可特殊召唤的「兽带斗神」怪兽时，选择其中1只为对象。
function c48806195.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c48806195.spfilter(chkc,e,tp) end
	-- 检查自己的主要怪兽区是否有可用空格，确保对象可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔法与陷阱区域是否存在1只表侧表示且可特殊召唤的「兽带斗神」怪兽。
		and Duel.IsExistingTarget(c48806195.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 向对方玩家提示“对方选择了：...”并显示本效果的描述，明示发动了哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己魔法与陷阱区域选择1只可特殊召唤的「兽带斗神」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c48806195.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：选中的对象将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将作为对象的魔陷区「兽带斗神」怪兽特殊召唤到自己的主要怪兽区。
function c48806195.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的魔陷区对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断场上怪兽是否为装备了这张卡的「兽带斗神」怪兽，作为授予效果的对象。
function c48806195.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 判断这张装备卡当前的装备对象是否为「兽带斗神」怪兽，是则提供攻击力上升效果。
function c48806195.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
