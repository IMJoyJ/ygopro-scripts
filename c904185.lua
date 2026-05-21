--垂直着陸
-- 效果：
-- 把衍生物以外的自己场上的风属性怪兽任意数量解放才能发动。解放的怪兽数量的「幻兽机衍生物」（机械族·风·3星·攻/守0）在自己场上特殊召唤。「垂直着陆」在1回合只能发动1张。
function c904185.initial_effect(c)
	-- 把衍生物以外的自己场上的风属性怪兽任意数量解放才能发动。解放的怪兽数量的「幻兽机衍生物」（机械族·风·3星·攻/守0）在自己场上特殊召唤。「垂直着陆」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,904185+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c904185.cost)
	e1:SetTarget(c904185.target)
	e1:SetOperation(c904185.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上可解放的、非衍生物的风属性怪兽
function c904185.rfilter(c,ft,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and not c:IsType(TYPE_TOKEN)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价：解放自己场上任意数量的非衍生物的风属性怪兽，并记录解放的数量
function c904185.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家怪兽区域的空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否至少存在1只可解放的满足条件的怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c904185.rfilter,1,nil,ft,tp) end
	local maxc=10
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then maxc=1 end
	-- 玩家选择任意数量满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c904185.rfilter,1,maxc,nil,ft,tp)
	e:SetLabel(g:GetCount())
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果的目标：检查是否能特殊召唤衍生物，并设置特殊召唤和产生衍生物的操作信息
function c904185.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以特殊召唤「幻兽机衍生物」
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置产生对应解放数量衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,e:GetLabel(),0,0)
	-- 设置特殊召唤对应解放数量怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),0,0)
end
-- 效果的处理：在自己场上特殊召唤与解放数量相同的「幻兽机衍生物」
function c904185.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家怪兽区域的空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<e:GetLabel() then return end
	-- 检查当前是否仍可特殊召唤「幻兽机衍生物」
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		for i=1,e:GetLabel() do
			-- 创建「幻兽机衍生物」卡片
			local token=Duel.CreateToken(tp,904186)
			-- 将衍生物以表侧表示特殊召唤到场上（单步处理）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
