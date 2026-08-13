--E・HERO グランドマン
-- 效果：
-- 「英雄」通常怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×300。
-- ②：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从额外卡组把1只「元素英雄」融合怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽不能向持有自身的等级以下的等级的怪兽攻击。
function c36841733.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，指定素材为2只满足“英雄”通常怪兽条件的怪兽，即这张卡可通过融合召唤登场。
	aux.AddFusionProcFunRep(c,c36841733.ffilter,2,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将该特殊召唤条件效果的判定设为只允许通过融合召唤方式特殊召唤（其他方式均不可）。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 作为这张卡的融合素材的怪兽的原本等级合计
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c36841733.valcheck)
	c:RegisterEffect(e0)
	-- ①：这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×300。
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
-- 定义融合素材过滤器：素材必须是「英雄」通常怪兽（同时具备通常怪兽类型和英雄字段）。
function c36841733.ffilter(c)
	return c:IsFusionType(TYPE_NORMAL) and c:IsFusionSetCard(0x8)
end
-- 素材等级合计检查：获取该卡融合召唤时使用的素材，累加所有素材怪兽的原本等级，将合计值记录到效果标签中。
function c36841733.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	-- 使用迭代器遍历素材组g中的每一张卡。
	for tc in aux.Next(g) do
		atk=atk+tc:GetOriginalLevel()
	end
	e:SetLabel(atk)
end
-- 攻守上升效果的发动条件：这张卡是以融合召唤方式成功特殊召唤（而非其他方式出场）。
function c36841733.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 攻击力·守备力上升操作：从素材检查效果中取出原本等级合计，乘以300，为自身分别追加攻击力和守备力，且此提升随卡离场等原因重置。
function c36841733.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabelObject():GetLabel()*300
	if atk>0 then
		-- 这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×300。
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
-- ②的发动条件：这张卡与战斗对象仍然关联（自身未被战斗破坏等），且战斗对象为怪兽，即发生了这张卡战斗破坏对方怪兽。
function c36841733.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsType(TYPE_MONSTER)
end
-- ②的发动代价：解放自身作为cost，同时检查自身是否可以被解放。
function c36841733.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价形式将这张卡解放送入墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤候选的过滤器：额外卡组的「元素英雄」融合怪兽，且可以被无视召唤条件特殊召唤，并且需要有空余的怪兽区域。
function c36841733.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 额外检查：在作为cost的素材怪兽离场后，额外卡组怪兽出场的可空区域数量必须大于0，以保证特殊召唤能成功。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②的发动目标：在发动时检查额外卡组是否存在符合条件的「元素英雄」融合怪兽，并设置特殊召唤的操作信息。
function c36841733.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认额外卡组中至少有1只满足条件的「元素英雄」融合怪兽可供特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c36841733.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②的效果处理：让玩家从额外卡组选择符合条件的「元素英雄」融合怪兽并特殊召唤，给其附加“不能攻击等级不高于自身的怪兽”的限制，然后完成特殊召唤。
function c36841733.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的额外卡组中选择1张满足spfilter的「元素英雄」融合怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c36841733.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 若选中目标且能进行无视召唤条件的特殊召唤，则执行特殊召唤步骤（中间阶段），并为成功特召的怪兽附加额外效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽不能向持有自身的等级以下的等级的怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetValue(c36841733.bttg)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成整个特殊召唤处理，使该效果的特召步骤正式生效。
	Duel.SpecialSummonComplete()
end
-- 定义攻击对象限制的过滤条件：被特殊召唤的怪兽不能选择表侧表示且等级不高于自身等级的怪兽作为攻击对象。
function c36841733.bttg(e,c)
	return c:IsFaceup() and c:IsLevelBelow(e:GetHandler():GetLevel())
end
