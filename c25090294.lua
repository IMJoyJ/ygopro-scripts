--ブルーメンブラット
-- 效果：
-- 把自己场上1只「元素英雄 小花蕾」作为祭品发动。从自己的手卡·卡组特殊召唤1只「元素英雄 鲜花女郎」。
function c25090294.initial_effect(c)
	-- 为卡片添加元素英雄系列编码，用于后续系列判断
	aux.AddSetNameMonsterList(c,0x3008)
	-- 把自己场上1只「元素英雄 小花蕾」作为祭品发动。从自己的手卡·卡组特殊召唤1只「元素英雄 鲜花女郎」。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c25090294.cost)
	e1:SetTarget(c25090294.target)
	e1:SetOperation(c25090294.activate)
	c:RegisterEffect(e1)
end
-- 定义祭品怪兽的过滤条件，必须是「元素英雄 小花蕾」且满足解放条件
function c25090294.costfilter(c,tp)
	return c:IsCode(62107981)
		-- 检查祭品怪兽是否满足解放条件，即其所在区域有空位且为己方控制或正面表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 设置效果的发动费用，要求选择1只符合条件的祭品怪兽并将其解放
function c25090294.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查是否满足发动费用条件，即场上存在符合条件的祭品怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c25090294.costfilter,1,nil,tp) end
	-- 选择1只符合条件的祭品怪兽
	local g=Duel.SelectReleaseGroup(tp,c25090294.costfilter,1,1,nil,tp)
	-- 将选中的祭品怪兽解放作为发动费用
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤目标怪兽的过滤条件，必须是「元素英雄 鲜花女郎」且可特殊召唤
function c25090294.filter(c,e,tp)
	return c:IsCode(51085303) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置效果的发动目标，检查是否满足特殊召唤条件并设置操作信息
function c25090294.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件，即祭品已支付或场上存在空位
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手牌与卡组中是否存在符合条件的「元素英雄 鲜花女郎」
		return res and Duel.IsExistingMatchingCard(c25090294.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置连锁操作信息，表示将特殊召唤1只「元素英雄 鲜花女郎」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 设置效果的发动处理，选择并特殊召唤符合条件的怪兽
function c25090294.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌与卡组中选择1只符合条件的「元素英雄 鲜花女郎」
	local g=Duel.SelectMatchingCard(tp,c25090294.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
