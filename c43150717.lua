--Xyz Lay
-- 效果：
-- 装备怪兽的攻击力上升场上的超量素材的数量×200。1回合1次，可以根据装备怪兽的种类从以下效果选择1个发动。
-- ●超量怪兽：自己场上2个超量素材取除；从卡组把1张「超量」魔法·陷阱卡在自己场上盖放。
-- ●那以外：从手卡把和装备怪兽等级相同的1只怪兽效果无效守备表示特殊召唤。
-- 「超量迭光」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册装备魔法卡的标准效果，包括装备目标选择、装备动作以及装备限制；设置该卡的发动次数限制为1次（誓约次数）
function s.initial_effect(c)
	-- 创建装备魔法卡的标准发动效果，允许装备给己方和对方场上的表侧表示怪兽，装备对象需满足Card.IsFaceup条件
	local e1=aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- 发动效果1：从卡组选择1张「超量」魔法·陷阱卡在自己场上盖放
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
	-- 发动效果2：从手卡把和装备怪兽等级相同的1只怪兽效果无效守备表示特殊召唤
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
	-- 装备怪兽的攻击力上升场上的超量素材的数量×200
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
end
-- 发动条件：装备怪兽为超量怪兽类型
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsType(TYPE_XYZ)
end
-- 发动费用：支付2个超量素材的取除作为代价
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付2个超量素材的取除作为代价
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST) end
	-- 执行2个超量素材的取除操作
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_COST)
end
-- 过滤函数：用于筛选可以盖放的「超量」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x73) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 发动目标：检查场上是否存在满足条件的「超量」魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否卡组中存在满足条件的「超量」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 发动处理：选择并盖放1张「超量」魔法·陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的「超量」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行盖放操作
		Duel.SSet(tp,tc)
	end
end
-- 发动条件：装备怪兽不为超量怪兽类型
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and not ec:IsType(TYPE_XYZ)
end
-- 过滤函数：用于筛选可以特殊召唤的怪兽（等级与装备怪兽相同）
function s.spfilter(c,e,tp,lv)
	return c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动目标：检查是否可以特殊召唤满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsLevelAbove(1)
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ec:GetLevel()) end
	-- 设置操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 发动处理：选择并特殊召唤1只怪兽，使其效果无效
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ec:GetLevel())
	local sc=g:GetFirst()
	-- 执行特殊召唤步骤并设置效果无效
	if #g>0 and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 设置特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		-- 设置特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 计算攻击力提升值：场上的超量素材数量×200
function s.atkval(e,c)
	-- 返回场上的超量素材数量×200作为攻击力提升值
	return Duel.GetOverlayCount(e:GetHandlerPlayer(),1,1)*200
end
