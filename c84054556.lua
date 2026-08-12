--終刻反転『A.D.R.A.S.T.E.I.A.』
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽1回合只有1次不会被战斗破坏。
-- ②：自己主要阶段才能发动。装备怪兽破坏，破坏的怪兽以外的自己的手卡·墓地·除外状态的1只「终刻」怪兽守备表示特殊召唤。
-- ③：这张卡在墓地存在的场合，以自己场上1只表侧表示怪兽为对象才能发动。这张卡给那只怪兽装备。那之后，自己受到装备怪兽的等级·阶级×100伤害。
local s,id,o=GetID()
-- 初始化函数，注册该卡作为装备魔法卡的基本效果、战斗代破效果、破坏并特召效果，以及墓地自我装备并给与伤害的效果
function s.initial_effect(c)
	-- 注册装备魔法卡的标准发动效果，允许装备给双方场上的表侧表示怪兽
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- ①：装备怪兽1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。装备怪兽破坏，破坏的怪兽以外的自己的手卡·墓地·除外状态的1只「终刻」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，以自己场上1只表侧表示怪兽为对象才能发动。这张卡给那只怪兽装备。那之后，自己受到装备怪兽的等级·阶级×100伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
-- 过滤破坏原因，仅在因战斗破坏时适用代破效果
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 过滤手卡、墓地、除外状态中可以守备表示特殊召唤的「终刻」怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1d2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②（破坏并特召）的发动准备与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查是否存在装备怪兽，且该怪兽离开场上后是否有可用的怪兽区域
	if chk==0 then return ec and Duel.GetMZoneCount(tp,ec)>0
		-- 检查手卡、墓地、除外状态是否存在至少1只满足特召条件的「终刻」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁运营信息，表示该效果包含破坏装备怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
	-- 设置连锁运营信息，表示该效果包含从手卡、墓地、除外状态特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②（破坏并特召）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查装备怪兽是否存在，并执行破坏，若破坏失败则终止后续处理
	if not ec or Duel.Destroy(ec,REASON_EFFECT)==0 then return end
	-- 检查己方场上是否有可用的怪兽区域，若无则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、墓地、除外状态选择1只除刚才被破坏的怪兽以外的、且不受「王家之谷」影响的「终刻」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,ec,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤场上表侧表示的怪兽，作为墓地装备效果的合法对象
function s.eqfilter2(c)
	return c:IsFaceup()
end
-- 获取怪兽的等级或阶级，若两者皆无（如连接怪兽）则返回0
function s.lv_or_rk(c)
	if c:IsLevelAbove(1) then
		return c:GetLevel()
	elseif c:IsRankAbove(1) then
		return c:GetRank()
	else
		return 0
	end
end
-- 效果③（墓地自我装备并伤害）的发动准备与对象选择
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter2(chkc) end
	-- 检查己方魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查己方场上是否存在可以作为装备对象的表侧表示怪兽
		and Duel.IsExistingTarget(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil)
		and c:CheckUniqueOnField(tp) end
	-- 提示玩家选择要装备的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择己方场上1只表侧表示怪兽作为效果对象
	local tc=Duel.SelectTarget(tp,s.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	-- 设置连锁运营信息，表示该效果包含将自身作为装备卡装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置连锁运营信息，表示该效果包含卡片离开墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	local lr=s.lv_or_rk(tc)
	if lr>0 then
		-- 设置连锁运营信息，表示该效果包含给与玩家伤害的操作
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,lr*100)
	end
end
-- 效果③（墓地自我装备并伤害）的效果处理函数
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER)
		-- 检查自身是否不受「王家之谷」影响，且在场上只能存在1张同名卡
		and aux.NecroValleyFilter()(c) and c:CheckUniqueOnField(tp)
		-- 执行装备操作，并检查装备是否成功以及装备怪兽的等级或阶级是否大于0
		and Duel.Equip(tp,c,tc) and s.lv_or_rk(tc)>0 then
		-- 中断当前效果处理，使后续的伤害处理与装备处理不视为同时进行
		Duel.BreakEffect()
		-- 给与玩家等同于装备怪兽的等级或阶级乘以100的数值的伤害
		Duel.Damage(tp,s.lv_or_rk(tc)*100,REASON_EFFECT)
	end
end
