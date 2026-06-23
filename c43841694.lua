--魔導書の奇跡
-- 效果：
-- 选择自己墓地1只魔法师族超量怪兽和从游戏中除外的最多2张自己的名字带有「魔导书」的魔法卡才能发动。选择的怪兽特殊召唤，把选择的名字带有「魔导书」的魔法卡在那只怪兽下面重叠作为超量素材。「魔导书的奇迹」在1回合只能发动1张。
function c43841694.initial_effect(c)
	-- 效果设置：将此卡注册为发动时点效果，可选择对象，发动次数限制为1次，效果分类为特殊召唤
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
-- 过滤器函数：用于筛选满足条件的魔法师族超量怪兽（可特殊召唤）
function c43841694.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤器函数：用于筛选满足条件的魔法卡（名字带有「魔导书」且可叠放）
function c43841694.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsCanOverlay()
end
-- 效果发动时点判断：检查是否满足发动条件（有空场、墓地有魔法师族超量怪兽、除外区有魔导书魔法卡）
function c43841694.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件：检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：检查玩家墓地是否存在魔法师族超量怪兽
		and Duel.IsExistingTarget(c43841694.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断是否满足发动条件：检查玩家除外区是否存在名字带有「魔导书」的魔法卡
		and Duel.IsExistingTarget(c43841694.filter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示选择：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从玩家墓地选择1只魔法师族超量怪兽作为特殊召唤对象
	local g1=Duel.SelectTarget(tp,c43841694.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 提示选择：提示玩家选择要作为超量素材的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标：从玩家除外区选择1~2张名字带有「魔导书」的魔法卡作为超量素材
	local g2=Duel.SelectTarget(tp,c43841694.filter2,tp,LOCATION_REMOVED,0,1,2,nil)
	-- 设置操作信息：设置本次效果将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 过滤器函数：用于筛选满足条件的魔法卡（与效果相关、名字带有「魔导书」且可叠放）
function c43841694.ovfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsCanOverlay()
end
-- 效果处理函数：处理效果发动后的操作，包括特殊召唤怪兽和叠放魔法卡
function c43841694.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡组：获取本次效果选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=e:GetLabelObject()
	local sg=g:Filter(c43841694.ovfilter,tc,e)
	-- 特殊召唤处理：将选择的怪兽特殊召唤到场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果：使后续处理视为错时点处理
		Duel.BreakEffect()
		if sg:GetCount()>0 then
			-- 叠放处理：将选择的魔法卡叠放到特殊召唤的怪兽下面
			Duel.Overlay(tc,sg)
		end
	end
end
