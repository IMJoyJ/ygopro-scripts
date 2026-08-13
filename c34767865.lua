--サイバネット・リチューアル
-- 效果：
-- 电子界族仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只电子界族仪式怪兽仪式召唤。
-- ②：自己场上没有怪兽存在的场合，从自己墓地把这张卡和1只仪式怪兽除外才能发动。在自己场上把2只「电脑网衍生物」（电子界族·光·4星·攻/守0）特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c34767865.initial_effect(c)
	-- 为「电脑网仪式」注册①效果的仪式召唤程序：从手卡·场上解放怪兽，直到等级合计不低于要仪式召唤的电子界族仪式怪兽，并从手卡进行仪式召唤（支持等级溢出）。
	aux.AddRitualProcGreater2(c,c34767865.ritual_filter)
	-- ②：自己场上没有怪兽存在的场合，从自己墓地把这张卡和1只仪式怪兽除外才能发动。在自己场上把2只「电脑网衍生物」（电子界族·光·4星·攻/守0）特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetDescription(aux.Stringid(34767865,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c34767865.spcon)
	e1:SetCost(c34767865.spcost)
	e1:SetTarget(c34767865.sptg)
	e1:SetOperation(c34767865.spop)
	c:RegisterEffect(e1)
end
-- 定义可被「电脑网仪式」仪式召唤的怪兽范围：必须是电子界族仪式怪兽。
function c34767865.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_CYBERSE)
end
-- ②效果的发动条件判断函数：在满足『这张卡送去墓地的回合不能发动』的限制外，还要求自己场上没有怪兽。
function c34767865.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果的具体发动条件：此卡不是在本回合被送去墓地（满足aux.exccon），且自己场上没有任何怪兽。
	return aux.exccon(e) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义可作为②效果代价从墓地除外的仪式怪兽条件：必须是仪式怪兽、是怪兽卡，且可以作为代价除外。
function c34767865.cfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价检查阶段（chk==0）：确认这张卡自身可作为代价除外，且墓地存在至少1只满足cfilter的仪式怪兽（不包含这张卡自身）。
function c34767865.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 并且墓地存在至少1只（除这张卡自身外）满足cfilter条件、可作为代价除外的仪式怪兽。
		and Duel.IsExistingMatchingCard(c34767865.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 发送『请选择要除外的卡』的选择提示，让玩家选择要作为代价除外的墓地仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足cfilter的仪式怪兽（排除这张卡自身），用于作为②效果的代价。
	local g=Duel.SelectMatchingCard(tp,c34767865.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将g中的仪式怪兽与这张卡一起以表侧表示从墓地除外，作为②效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标设定函数：发动前确认没有『青眼精灵龙』的“不能同时特殊召唤2只以上怪兽”限制，且可用怪兽区空格>1、玩家可以特殊召唤衍生物，满足则允许发动。
function c34767865.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定自己场上可用的怪兽区域空格数大于1，以保证能够同时特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判定当前玩家tp可以特殊召唤「电脑网衍生物」（34767866：电子界族·光·4星·攻/守0）到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34767866,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 登记操作信息：本次效果将在tp场上特殊召唤2只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	-- 登记操作信息：本次效果包含对2只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON），目标玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
-- ②效果的实际处理函数：再次确认青眼精灵龙限制、可用的怪兽区域数量及特殊召唤衍生物的许可后，依次特殊召唤2只「电脑网衍生物」，最后完成连续特殊召唤。
function c34767865.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查：如果自己场上可用的怪兽区域少于2个，则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时再次检查：如果当前玩家不能特殊召唤「电脑网衍生物」，则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,34767866,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_CYBERSE,ATTRIBUTE_LIGHT) then return end
	for i=1,2 do
		-- 创建1只「电脑网衍生物」（34767866）衍生物，由tp玩家持有。
		local token=Duel.CreateToken(tp,34767866)
		-- 将该衍生物以表侧表示由tp特殊召唤到tp场上（作为连续特殊召唤的一步）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 结束连续特殊召唤流程，统一处理特殊召唤成功后的时点与诱发效果。
	Duel.SpecialSummonComplete()
end
