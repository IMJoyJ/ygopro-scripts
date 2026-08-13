--小天使テルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从怪兽区域送去墓地的场合才能发动。在自己场上把1只「忒勒斯的羽翼衍生物」（天使族·光·1星·攻/守0）特殊召唤。
-- ②：自己场上有「忒勒斯的羽翼衍生物」存在的场合，把墓地的这张卡和手卡1张魔法卡除外才能发动。在自己场上把2只「忒勒斯的羽翼衍生物」特殊召唤。这个效果的发动后，直到回合结束时自己不是从手卡中不能把怪兽特殊召唤。
function c19280589.initial_effect(c)
	-- ①：这张卡从怪兽区域送去墓地的场合才能发动。在自己场上把1只「忒勒斯的羽翼衍生物」（天使族·光·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19280589,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,19280589)
	e1:SetCondition(c19280589.tkcon1)
	e1:SetTarget(c19280589.tktg1)
	e1:SetOperation(c19280589.tkop1)
	c:RegisterEffect(e1)
	-- ②：自己场上有「忒勒斯的羽翼衍生物」存在的场合，把墓地的这张卡和手卡1张魔法卡除外才能发动。在自己场上把2只「忒勒斯的羽翼衍生物」特殊召唤。这个效果的发动后，直到回合结束时自己不是从手卡中不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19280589,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,19280590)
	e2:SetCost(c19280589.tkcost2)
	e2:SetCondition(c19280589.tkcon2)
	e2:SetTarget(c19280589.tktg2)
	e2:SetOperation(c19280589.tkop2)
	c:RegisterEffect(e2)
end
-- 效果发动条件：检查此卡发动前是否位于主要怪兽区域，即确实是从怪兽区域被送去墓地，才满足①的触发条件。
function c19280589.tkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- ①的发动准备（目标检查）：确认我方主要怪兽区域有空位，且玩家当前能够特殊召唤「忒勒斯的羽翼衍生物」，满足条件才可发动并设定处理信息。
function c19280589.tktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区域是否有至少1个空位，作为①的发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家能够特殊召唤「忒勒斯的羽翼衍生物」（天使族·光·1星·攻/守0），作为①的发动条件之一。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 向连锁处理系统登记本次效果将生成1只衍生物（CATEGORY_TOKEN），供相关卡牌效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向连锁处理系统登记本次效果将进行1只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON），供相关卡牌效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①的效果处理：再次确认场地和特殊召唤可行性，若可以则生成1只「忒勒斯的羽翼衍生物」并表侧表示特殊召唤到我方场上。
function c19280589.tkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若我方主要怪兽区域已无空位，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认玩家可以特殊召唤该衍生物，才会继续生成token。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		-- 创建1只「忒勒斯的羽翼衍生物」，控制者为我方玩家。
		local token=Duel.CreateToken(tp,19280590)
		-- 将衍生物以表侧表示特殊召唤到我方主要怪兽区域。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义代价筛选条件：从手卡选择1张魔法卡，并且该卡可以作为代价被除外。
function c19280589.tkcsfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ②的代价处理：从手卡选1张魔法卡，加上墓地的这张卡一起除外作为发动代价；同时处理发动提示。
function c19280589.tkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价合法性检查：手卡中存在可除外的魔法卡，且墓地的这张卡本身也能作为代价除外，才满足②的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c19280589.tkcsfilter,tp,LOCATION_HAND,0,1,c) and c:IsAbleToRemoveAsCost() end
	-- 显示选择提示，让玩家选择要除外的卡片（用于从手卡选魔法卡作为代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1张符合条件的魔法卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c19280589.tkcsfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的魔法卡与墓地的这张卡一起以表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义场上衍生物的判定条件：表侧表示且卡号为19280590（忒勒斯的羽翼衍生物）。
function c19280589.ctkfilter(c)
	return c:IsFaceup() and c:IsCode(19280590)
end
-- ②的发动条件：检查我方场上是否存在至少1只表侧表示的「忒勒斯的羽翼衍生物」。
function c19280589.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 通过过滤函数查找我方场上是否存在满足条件的「忒勒斯的羽翼衍生物」，存在则返回true。
	return Duel.IsExistingMatchingCard(c19280589.ctkfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②的发动目标检查：场上未被「青眼精灵龙」封锁、我方主要怪兽区域至少2个空位、且可以特殊召唤衍生物，才满足②的发动条件。
function c19280589.tktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 需要至少2个主要怪兽区域空位，因为②要特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认玩家能够特殊召唤「忒勒斯的羽翼衍生物」，以满足②的发动条件。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 向连锁处理系统登记本次效果将生成2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 向连锁处理系统登记本次效果将进行2只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②的效果处理：在满足条件时生成2只「忒勒斯的羽翼衍生物」特殊召唤；随后给本方附加『不是从手卡不能特殊召唤怪兽』的自肃效果直到回合结束。
function c19280589.tkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认可以特殊召唤衍生物后，才进入循环生成2只token的处理。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,19280590,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		for i=1,2 do
			-- 创建1只「忒勒斯的羽翼衍生物」。
			local token=Duel.CreateToken(tp,19280590)
			-- 将衍生物表侧表示特殊召唤到我方场上。
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是从手卡中不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19280589.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果（不能从手卡以外特殊召唤）注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定：若怪兽不在手卡则不能特殊召唤，即本回合自己只能从手卡把怪兽特殊召唤。
function c19280589.splimit(e,c)
	return not c:IsLocation(LOCATION_HAND)
end
