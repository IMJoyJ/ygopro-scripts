--セリオンズ“キング”レギュラス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或机械族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备魔法卡使用给这张卡装备。
-- ②：对方把效果发动时，从自己的手卡·场上（表侧表示）把1张「兽带斗神」怪兽卡送去墓地才能发动。那个效果无效。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
local s,id,o=GetID()
-- 创建并注册①效果：从手卡特殊召唤并装备墓地怪兽
function c10604644.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或机械族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10604644,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,10604644)
	e1:SetTarget(c10604644.sptg)
	e1:SetOperation(c10604644.spop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时，从自己的手卡·场上（表侧表示）把1张「兽带斗神」怪兽卡送去墓地才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10604644,1))  --"对方效果无效（兽带斗神“王者”轩辕十四）"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10604644+o)
	e2:SetCondition(c10604644.discon)
	e2:SetCost(c10604644.discost)
	e2:SetTarget(c10604644.distg)
	e2:SetOperation(c10604644.disop)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c10604644.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 装备效果：使装备怪兽攻击力上升700点
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c10604644.atkcon)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断是否为机械族或兽带斗神族怪兽且未在场上重复
function c10604644.eqfilter(c,tp)
	return (c:IsRace(RACE_MACHINE) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①效果的发动条件判断：检查是否有足够的怪兽区和魔陷区，以及是否存在满足条件的墓地目标
function c10604644.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c10604644.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 检查手卡特殊召唤的怪兽区是否可用
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c10604644.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标墓地怪兽作为装备对象
	local sg=Duel.SelectTarget(tp,c10604644.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：将目标怪兽从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置操作信息：将自身从手卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：执行特殊召唤并装备目标怪兽
function c10604644.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否可以特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 执行特殊召唤操作
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取目标怪兽
		local tc=Duel.GetFirstTarget()
		-- 检查目标怪兽是否有效且魔陷区是否可用
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 执行装备操作
			Duel.Equip(tp,tc,c,false)
			-- 设置装备限制效果：确保该装备卡只能被特定怪兽装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c10604644.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备限制效果的判断函数：判断目标是否为装备卡的拥有者
function c10604644.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动条件：判断是否为对方发动效果
function c10604644.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 过滤函数：判断是否为兽带斗神族怪兽且可作为墓地代价
function c10604644.cfilter(c)
	return c:IsSetCard(0x179) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- ②效果的发动费用：选择并送入墓地一张兽带斗神族怪兽
function c10604644.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的怪兽可作为墓地代价
	if chk==0 then return Duel.IsExistingMatchingCard(c10604644.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送入墓地的兽带斗神族怪兽
	local g=Duel.SelectMatchingCard(tp,c10604644.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的怪兽送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标设定：设置效果无效的目标
function c10604644.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家已选择该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果的处理函数：使对方效果无效
function c10604644.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
-- ③效果的目标过滤函数：判断是否为装备了该装备卡的兽带斗神族怪兽
function c10604644.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- ③效果的发动条件：判断装备目标是否为兽带斗神族怪兽
function c10604644.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
