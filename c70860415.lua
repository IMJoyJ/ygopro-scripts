--X－クロス・キャノン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：机械族·光属性的，融合怪兽或同盟怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。可以给这张卡装备的1只机械族·光属性同盟怪兽当作那个效果的装备魔法卡使用从卡组给这张卡装备。这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤效果和从卡组装备同盟怪兽效果
function s.initial_effect(c)
	-- ①：机械族·光属性的，融合怪兽或同盟怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。可以给这张卡装备的1只机械族·光属性同盟怪兽当作那个效果的装备魔法卡使用从卡组给这张卡装备。这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.has_text_type=TYPE_UNION
-- 过滤条件：场上表侧表示的机械族·光属性的融合怪兽或同盟怪兽
function s.cfilter(c)
	return c:IsType(TYPE_UNION+TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
-- 特殊召唤效果的发动条件：自己场上存在满足过滤条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中可以装备给这张卡的机械族·光属性同盟怪兽
function s.eqfilter(c,tc,tp)
	-- 检查该卡是否为同盟怪兽，且是否能作为同盟卡装备给目标怪兽
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION)
		and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 装备效果的发动准备与合法性检查
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 获取自己场上可用的魔法与陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 检查魔法与陷阱区域是否有空位，且卡组中是否存在可装备的同盟怪兽
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp) end
	-- 设置连锁处理中的操作信息：从卡组装备1张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
-- 装备效果的执行函数，包含装备处理和后续的额外卡组特殊召唤限制
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在场上表侧表示存在，且魔法与陷阱区域是否有空位
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组中选择1只满足过滤条件的同盟怪兽
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,c,tp)
		local ec=g:GetFirst()
		-- 如果成功选择卡片，且满足同盟装备条件，则将其作为装备卡装备给这张卡
		if ec and aux.CheckUnionEquip(ec,c) and Duel.Equip(tp,ec,c) then
			-- 设置该装备卡为同盟状态
			aux.SetUnionState(ec)
		end
	end
	-- 这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制玩家从额外卡组特殊召唤非光属性怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤非光属性的额外卡组怪兽
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_EXTRA)
end
