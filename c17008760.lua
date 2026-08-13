--原質の円環炉
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上1个超量素材取除。取除的超量素材被送去自己墓地的场合，可以再把那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化该卡的效果：新建效果e1，设置其描述、分类（特殊召唤/从墓地特殊召唤/盖放魔法陷阱/盖放怪兽）、类型为魔法·陷阱卡发动、发动时机为自由时点，并设定同名卡1回合1次（誓约计数），再注册发动条件和效果处理函数。
function s.initial_effect(c)
	-- 对应原始效果：‘这个卡名的卡在1回合只能发动1张。①：自己场上1个超量素材取除。取除的超量素材被送去自己墓地的场合，可以再把那张卡在自己场上盖放。’；SetCountLimit实现同名卡1回合1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SSET+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：满足‘自己场上存在至少1个可以因效果取除的超量素材’时才视为合法发动；chk==0为发动前检查。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0分支：若tp不能以REASON_EFFECT从自己场上取除1个超量素材，则效果不能发动。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
end
-- 效果处理：先选择自己场上1只带有可取除超量素材的怪兽并取除其1个素材；若该素材进入自己墓地且不受王家长眠之谷影响，则根据其种类（怪兽或魔法陷阱）在征询玩家后，以里侧守备表示特殊召唤或盖放到魔陷区/场地区，并向对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 发出选择提示，告知玩家接下来要选择用于取除超量素材的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 在自己场上筛选并选择1张可移除超量素材的卡；过滤条件附带tp、1、REASON_EFFECT，表示以效果原因取除1个素材。该选择不指定对象。
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,0,1,1,nil,tp,1,REASON_EFFECT)
	if sg:GetCount()==0 then return end
	if sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
		-- Duel.GetOperatedGroup获取刚才取除超量素材操作中实际被移除的卡，GetFirst取出该卡作为后续处理对象。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 确认被取除的素材卡存在、控制者为发动玩家且位于墓地，并通过王家长眠之谷过滤，保证能从墓地移动后，才继续处理。
		if tc and tc:IsControler(tp) and tc:IsLocation(LOCATION_GRAVE) and aux.NecroValleyFilter()(tc) then
			-- 若该卡是怪兽，且自己主要怪兽区有空位，并且它可以以里侧守备表示特殊召唤，则进入怪兽盖放分支。
			if tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
				-- 弹出‘是否把那张卡盖放？’的选择，只有玩家同意才执行后续特殊召唤。
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把那张卡盖放？"
				-- 中断当前效果处理，使之后的特殊召唤不与取除素材视为同时处理，以避免错过召唤成功的时点。
				Duel.BreakEffect()
				-- 将该怪兽卡以里侧守备表示特殊召唤到自己场上（不附加召唤类型，但检查召唤条件和苏生限制）。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				-- 特殊召唤后，向对方玩家确认该里侧守备表示的怪兽卡的卡面信息。
				Duel.ConfirmCards(1-tp,tc)
			-- 若该卡是场地魔法或自己魔法陷阱区有空位，则进入魔法·陷阱盖放分支。
			elseif (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
				-- 确认该卡可以盖放到魔法陷阱区（场地魔法视为可盖放），并征询玩家决定是否盖放。
				and tc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把那张卡盖放？"
				-- 同样中断当前效果处理，使后续盖放不被视为与取除素材同时处理。
				Duel.BreakEffect()
				-- 将这张卡盖放至自己场上：魔法陷阱卡盖放到魔法陷阱区，场地魔法盖放到场地区。
				Duel.SSet(tp,tc)
			end
		end
	end
end
