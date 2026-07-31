--エクシーズ・レイ
-- 效果：
-- 装备怪兽的攻击力上升场上的超量素材的数量×200。1回合1次，可以根据装备怪兽的种类从以下效果选择1个发动。
-- ●超量怪兽：自己场上2个超量素材取除；从卡组把1张「超量」魔法·陷阱卡在自己场上盖放。
-- ●那以外：从手卡把和装备怪兽等级相同的1只怪兽效果无效守备表示特殊召唤。
-- 「超量迭光」在1回合只能发动1张。
local s,id,o=GetID()
-- 初始化装备魔法卡效果，注册装备效果和两个发动效果
function s.initial_effect(c)
	-- 添加装备魔法卡的基本装备逻辑，允许装备给己方和对方怪兽，且装备怪兽必须表侧表示
	local e1=aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- 设置第一个发动效果为盖放魔法·陷阱卡，条件是装备怪兽为超量怪兽
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
	-- 设置第二个发动效果为特殊召唤怪兽，条件是装备怪兽不是超量怪兽
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
	-- 设置装备怪兽攻击力上升场上的超量素材数量×200的效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
end
-- 判断装备怪兽是否为超量怪兽以触发盖放效果
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsType(TYPE_XYZ)
end
-- 支付盖放效果的费用，移除自己场上2个超量素材
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除2个超量素材作为盖放效果的费用
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,2,REASON_COST) end
	-- 执行移除2个超量素材的操作
	Duel.RemoveOverlayCard(tp,1,0,2,2,REASON_COST)
end
-- 定义用于筛选可盖放的「超量」魔法·陷阱卡的过滤函数
function s.setfilter(c)
	return c:IsSetCard(0x73) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置盖放效果的目标检测，检查卡组中是否存在符合条件的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的「超量」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行盖放效果的操作，选择并盖放一张符合条件的卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择符合条件的「超量」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡盖放到场上
		Duel.SSet(tp,tc)
	end
end
-- 判断装备怪兽是否不是超量怪兽以触发特殊召唤效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and not ec:IsType(TYPE_XYZ)
end
-- 定义用于筛选可特殊召唤的怪兽的过滤函数，要求等级与装备怪兽相同且能守备表示特殊召唤
function s.spfilter(c,e,tp,lv)
	return c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤效果的目标检测，检查手牌中是否存在符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsLevelAbove(1)
		-- 检查手牌中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,ec:GetLevel()) end
	-- 设置特殊召唤效果的操作信息，确定要处理的卡的数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤效果的操作，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查场上是否还有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ec:GetLevel())
	local sc=g:GetFirst()
	-- 判断是否成功特殊召唤了怪兽并设置其效果无效
	if #g>0 and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 为特殊召唤的怪兽添加效果无效的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		-- 为特殊召唤的怪兽添加效果无效的效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程，确保所有特殊召唤步骤结束
	Duel.SpecialSummonComplete()
end
-- 计算装备怪兽攻击力上升值，等于场上超量素材数量×200
function s.atkval(e,c)
	-- 返回场上超量素材数量乘以200作为攻击力提升值
	return Duel.GetOverlayCount(e:GetHandlerPlayer(),1,1)*200
end
