--エクシーズ・レイ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：装备怪兽的攻击力上升场上的超量素材数量×200。
-- ②：1回合1次，可以把装备怪兽的种类的以下效果发动。
-- ●超量怪兽：把自己场上2个超量素材取除才能发动。从卡组把1张「超量」魔法·陷阱卡在自己场上盖放。
-- ●那以外：把持有和装备怪兽的等级相同等级的1只怪兽从手卡守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
local s,id,o=GetID()
-- 注册装备魔法的通用装备效果（此卡1回合只能发动1张），以及盖放、特殊召唤、攻击力上升三个效果
function s.initial_effect(c)
	-- 为此卡添加通用装备魔法效果，可装备给双方场上表侧表示的怪兽
	local e1=aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ②：1回合1次，可以把装备怪兽的种类的以下效果发动。●超量怪兽：把自己场上2个超量素材取除才能发动。从卡组把1张「超量」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，可以把装备怪兽的种类的以下效果发动。●那以外：把持有和装备怪兽的等级相同等级的1只怪兽从手卡守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ①：装备怪兽的攻击力上升场上的超量素材数量×200。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
end
-- 发动条件：装备怪兽存在且为超量怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsType(TYPE_XYZ)
end
-- 发动代价：从自己场上取除2个超量素材
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以取除的2个超量素材作为代价
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST) end
	-- 从自己场上取除2个超量素材作为代价
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_COST)
end
-- 过滤条件：卡为「超量」魔法·陷阱卡且可以盖放
function s.setfilter(c)
	return c:IsSetCard(0x73) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果目标检查：确认卡组中有可以盖放的「超量」魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中存在至少1张可以盖放的「超量」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选1张「超量」魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张可以盖放的「超量」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 发动条件：装备怪兽存在且不是超量怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and not ec:IsType(TYPE_XYZ)
end
-- 过滤条件：怪兽的等级和装备怪兽的等级相同，且可以表侧守备表示特殊召唤
function s.spfilter(c,e,tp,lv)
	return c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果目标检查：确认主要怪兽区有空位、装备怪兽持有等级，且手卡中有与之等级相同的可特殊召唤怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查自己的主要怪兽区是否有可使用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsLevelAbove(1)
		-- 确认手卡中存在至少1只和装备怪兽等级相同、可以表侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ec:GetLevel()) end
	-- 设置操作信息：将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡把1只和装备怪兽等级相同的怪兽守备表示特殊召唤，并将其效果无效化
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 若自己的主要怪兽区没有空格则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只和装备怪兽等级相同、可以表侧守备表示特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ec:GetLevel())
	local sc=g:GetFirst()
	-- 若已选择卡片，则将选择的怪兽以表侧守备表示特殊召唤
	if #g>0 and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
	end
	-- 完成本次特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 计算攻击力上升值：场上的超量素材数量×200
function s.atkval(e,c)
	-- 返回场上（双方）的超量素材总数乘以200作为攻击力上升值
	return Duel.GetOverlayCount(e:GetHandlerPlayer(),1,1)*200
end
