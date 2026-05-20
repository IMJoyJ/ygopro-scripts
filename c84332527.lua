--セリオンズ“ブルズ”アイン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或者战士族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：以自己场上1张「兽带斗神」卡和对方场上1张卡为对象才能发动。那些卡破坏。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
local s,id,o=GetID()
-- 初始化效果：注册①手卡特召并装备墓地怪兽、②破坏己方兽带斗神卡和对方卡、③授予装备怪兽攻击力上升及②效果。
function c84332527.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或者战士族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84332527,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,84332527)
	e1:SetTarget(c84332527.sptg)
	e1:SetOperation(c84332527.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张「兽带斗神」卡和对方场上1张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84332527,1))  --"双方卡破坏（兽带斗神“公牛”毕宿一）"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,84332527+o)
	e2:SetTarget(c84332527.destg)
	e2:SetOperation(c84332527.desop)
	c:RegisterEffect(e2)
	-- 得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c84332527.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 有这张卡装备的「兽带斗神」怪兽攻击力上升700
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c84332527.atkcon)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地的战士族怪兽或「兽带斗神」怪兽，且该怪兽在场上唯一存在（可作为装备卡使用）。
function c84332527.eqfilter(c,tp)
	return (c:IsRace(RACE_WARRIOR) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- 特殊召唤效果的靶向/发动条件判定与目标选择。
function c84332527.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c84332527.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 判定己方怪兽区域和魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己墓地是否存在满足装备条件的怪兽。
		and Duel.IsExistingTarget(c84332527.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要装备的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象。
	local sg=Duel.SelectTarget(tp,c84332527.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置连锁运营信息：涉及卡片离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置连锁运营信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤自身并装备目标怪兽的效果处理。
function c84332527.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查己方怪兽区是否有空位，且自身卡片是否仍与效果相关联。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将自身以表侧表示特殊召唤，并判定是否特殊召唤成功。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取发动的对象卡片（即墓地的目标怪兽）。
		local tc=Duel.GetFirstTarget()
		-- 检查目标怪兽是否仍与效果相关联，且己方魔陷区是否有空位。
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 将目标怪兽作为装备卡装备给自身。
			Duel.Equip(tp,tc,c,false)
			-- 作为对象的怪兽当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c84332527.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 限制装备卡只能装备在效果来源卡片（自身）上。
function c84332527.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤场上表侧表示的「兽带斗神」卡片。
function c84332527.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x179)
end
-- 破坏效果的靶向/发动条件判定与目标选择。
function c84332527.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定己方场上是否存在表侧表示的「兽带斗神」卡片。
	if chk==0 then return Duel.IsExistingTarget(c84332527.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判定对方场上是否存在任意卡片。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择己方场上1张表侧表示的「兽带斗神」卡片作为破坏对象。
	local g1=Duel.SelectTarget(tp,c84332527.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡片作为破坏对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁运营信息：破坏选定的2张卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 破坏效果的处理：获取并破坏仍存在于场上的目标卡片。
function c84332527.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 因效果将目标卡片破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 过滤获得效果的对象：装备了这张卡的「兽带斗神」怪兽。
function c84332527.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 判定攻击力上升效果的适用条件：自身作为装备卡装备在「兽带斗神」怪兽上。
function c84332527.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
