--E・HERO グランドマン
-- 效果：
-- 「英雄」通常怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×300。
-- ②：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从额外卡组把1只「元素英雄」融合怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽不能向持有自身的等级以下的等级的怪兽攻击。
function c36841733.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c36841733.ffilter,2,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡必须通过融合召唤方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 检查融合素材并计算其原始等级总和
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c36841733.valcheck)
	c:RegisterEffect(e0)
	-- 融合召唤成功时，将融合素材的原始等级总和×300加到攻击力和守备力上
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c36841733.atkcon)
	e2:SetOperation(c36841733.atkop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从额外卡组把1只「元素英雄」融合怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽不能向持有自身的等级以下的等级的怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36841733,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c36841733.spcon)
	e3:SetCost(c36841733.spcost)
	e3:SetTarget(c36841733.sptg)
	e3:SetOperation(c36841733.spop)
	c:RegisterEffect(e3)
end
c36841733.material_setcode=0x8
-- 过滤函数，用于筛选融合素材，必须是通常怪兽且属于英雄卡组
function c36841733.ffilter(c)
	return c:IsFusionType(TYPE_NORMAL) and c:IsFusionSetCard(0x8)
end
-- 遍历融合素材，累加其原始等级并保存到效果标签中
function c36841733.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	-- 遍历融合素材组中的每张卡
	for tc in aux.Next(g) do
		atk=atk+tc:GetOriginalLevel()
	end
	e:SetLabel(atk)
end
-- 判断该卡是否为融合召唤 summoned
function c36841733.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 根据融合素材等级总和计算攻击力和守备力提升值，并应用到自身
function c36841733.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabelObject():GetLabel()*300
	if atk>0 then
		-- 提升自身攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
-- 判断是否满足发动条件：自身参与战斗且对方怪兽存在
function c36841733.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsType(TYPE_MONSTER)
end
-- 支付发动费用：解放自身
function c36841733.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价形式解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选额外卡组中可特殊召唤的「元素英雄」融合怪兽
function c36841733.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 检查是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置连锁操作信息，准备特殊召唤一张融合怪兽
function c36841733.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36841733.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁操作信息，准备特殊召唤一张融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果，选择并特殊召唤一张融合怪兽
function c36841733.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择一张满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c36841733.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 设置特殊召唤的怪兽不能攻击等级低于或等于自身的怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetValue(c36841733.bttg)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断目标怪兽等级是否低于或等于自身
function c36841733.bttg(e,c)
	return c:IsFaceup() and c:IsLevelBelow(e:GetHandler():GetLevel())
end
