--サイバネット・リチューアル
-- 效果：
-- 电子界族仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只电子界族仪式怪兽仪式召唤。
-- ②：自己场上没有怪兽存在的场合，从自己墓地把这张卡和1只仪式怪兽除外才能发动。在自己场上把2只「电脑网衍生物」（电子界族·光·4星·攻/守0）特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c34767865.initial_effect(c)
	-- 注册仪式召唤程序，条件为等级合计直到变成仪式召唤的怪兽的等级以上为止
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
-- 筛选可以被仪式召唤的电子界族仪式怪兽
function c34767865.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_CYBERSE)
end
-- 效果发动条件：这张卡在墓地且自己场上没有怪兽
function c34767865.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有怪兽存在
	return aux.exccon(e) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选可作为祭品的墓地仪式怪兽
function c34767865.cfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动费用：支付将此卡和1只仪式怪兽除外的代价
function c34767865.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 支付将1只仪式怪兽除外的代价
		and Duel.IsExistingMatchingCard(c34767865.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的墓地仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c34767865.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的卡除外作为效果发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时点的判定：检测是否可以特殊召唤2只衍生物
function c34767865.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 自己场上至少有2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 可以特殊召唤2只电脑网衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34767866,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 设置效果操作信息：将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	-- 设置效果操作信息：将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
-- 效果发动时的处理：特殊召唤2只电脑网衍生物
function c34767865.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 自己场上空位不足2个
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 无法特殊召唤2只电脑网衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,34767866,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_CYBERSE,ATTRIBUTE_LIGHT) then return end
	for i=1,2 do
		-- 创建一只电脑网衍生物
		local token=Duel.CreateToken(tp,34767866)
		-- 将创建的衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成特殊召唤处理
	Duel.SpecialSummonComplete()
end
