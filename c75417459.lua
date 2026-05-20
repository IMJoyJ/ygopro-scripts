--拘束解除
-- 效果：
-- ①：把自己场上1只「铁骑士 基亚·弗里德」解放才能发动。从手卡·卡组把1只「剑圣-赤膊的基亚·弗里德」特殊召唤。
function c75417459.initial_effect(c)
	-- ①：把自己场上1只「铁骑士 基亚·弗里德」解放才能发动。从手卡·卡组把1只「剑圣-赤膊的基亚·弗里德」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c75417459.cost)
	e1:SetTarget(c75417459.target)
	e1:SetOperation(c75417459.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的「铁骑士 基亚·弗里德」
function c75417459.costfilter(c,tp)
	return c:IsCode(423705)
		-- 检查该卡解放后是否能空出怪兽区域，且该卡必须由自己控制或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价：解放自己场上1只「铁骑士 基亚·弗里德」
function c75417459.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动检查阶段，检查场上是否存在可解放的「铁骑士 基亚·弗里德」
	if chk==0 then return Duel.CheckReleaseGroup(tp,c75417459.costfilter,1,nil,tp) end
	-- 选择自己场上1只「铁骑士 基亚·弗里德」解放
	local g=Duel.SelectReleaseGroup(tp,c75417459.costfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：手卡·卡组中可以特殊召唤的「剑圣-赤膊的基亚·弗里德」
function c75417459.filter(c,e,tp)
	return c:IsCode(57046845) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果的目标处理
function c75417459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果是作为发动代价解放了怪兽，或者当前怪兽区域有空位
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手卡·卡组是否存在可以特殊召唤的「剑圣-赤膊的基亚·弗里德」
		return res and Duel.IsExistingMatchingCard(c75417459.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置效果处理信息为：从手卡·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果的处理
function c75417459.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只「剑圣-赤膊的基亚·弗里德」
	local g=Duel.SelectMatchingCard(tp,c75417459.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若选取的卡片数量大于0，则将其无视召唤条件以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
