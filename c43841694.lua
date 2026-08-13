--魔導書の奇跡
-- 效果：
-- 选择自己墓地1只魔法师族超量怪兽和从游戏中除外的最多2张自己的名字带有「魔导书」的魔法卡才能发动。选择的怪兽特殊召唤，把选择的名字带有「魔导书」的魔法卡在那只怪兽下面重叠作为超量素材。「魔导书的奇迹」在1回合只能发动1张。
function c43841694.initial_effect(c)
	-- 选择自己墓地1只魔法师族超量怪兽和从游戏中除外的最多2张自己的名字带有「魔导书」的魔法卡才能发动。选择的怪兽特殊召唤，把选择的名字带有「魔导书」的魔法卡在那只怪兽下面重叠作为超量素材。「魔导书的奇迹」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43841694+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43841694.target)
	e1:SetOperation(c43841694.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选可被此效果特殊召唤的墓地魔法师族超量怪兽，必须是超量怪兽、魔法师族，且满足特殊召唤条件（不无视召唤条件与苏生限制）。
function c43841694.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：筛选可作为超量素材的除外区「魔导书」魔法卡，必须表侧表示、卡名属于「魔导书」字段、是魔法卡，且可以作为超量素材。
function c43841694.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsCanOverlay()
end
-- 效果发动时的目标选择函数：先处理连锁对象合法性查询，再在发动条件检查时确认己方怪兽区有空位、墓地存在符合条件的超量怪兽、除外区存在符合条件的「魔导书」魔法卡。
function c43841694.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件之一：己方主要怪兽区域存在空闲区域，用于后续特殊召唤超量怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之一：墓地存在至少1只满足filter的魔法师族超量怪兽，且能够成为此效果的对象。
		and Duel.IsExistingTarget(c43841694.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 发动条件之一：除外区存在至少1张满足filter2的「魔导书」魔法卡，且能够成为此效果的对象。
		and Duel.IsExistingTarget(c43841694.filter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择1只魔法师族超量怪兽作为效果对象，并登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,c43841694.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 向玩家显示选择提示，要求选择要作为超量素材的「魔导书」魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从己方除外区选择1~2张「魔导书」魔法卡作为效果对象，并登记为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,c43841694.filter2,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置当前连锁的操作信息：声明本效果包含特殊召唤，目标组为g1（墓地超量怪兽）数量1，供其他卡进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 处理阶段使用的过滤函数：从连锁对象中筛选仍然与此效果关联、属于「魔导书」字段、是魔法卡且可作为超量素材的卡。
function c43841694.ovfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsCanOverlay()
end
-- 效果处理函数：获取连锁对象，取出先前选择的墓地超量怪兽，筛选出可叠放的「魔导书」魔法卡；若怪兽仍关联且特殊召唤成功，则中断处理并将素材叠放。
function c43841694.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的全部对象卡（包括墓地超量怪兽和「魔导书」魔法卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=e:GetLabelObject()
	local sg=g:Filter(c43841694.ovfilter,tc,e)
	-- 判断选择的超量怪兽仍与此效果关联，并尝试将其表侧表示特殊召唤到己方场上；若特殊召唤成功则继续执行后续叠放处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使特殊召唤与后续的素材叠放分开处理，避免错过特殊召唤成功时的时点。
		Duel.BreakEffect()
		if sg:GetCount()>0 then
			-- 将选中的「魔导书」魔法卡叠放在已特殊召唤的超量怪兽下面，作为其超量素材。
			Duel.Overlay(tc,sg)
		end
	end
end
