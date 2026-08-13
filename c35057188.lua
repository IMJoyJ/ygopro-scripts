--B・F－革命のグラン・パルチザン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不会被效果破坏。
-- ②：自己场上的昆虫族同调怪兽的攻击力上升自己的除外状态的昆虫族怪兽数量×200。
-- ③：这张卡被除外的场合才能发动。这张卡特殊召唤。那之后，可以把最多有自己的除外状态的昆虫族怪兽数量的对方场上的卡破坏。那个场合，再给与对方破坏数量×500伤害。
local s,id,o=GetID()
-- 定义卡片的初始化函数：添加同调召唤手续和苏生限制，并依次注册①‘不会被效果破坏’、②‘昆虫族同调怪兽攻击力上升’、③‘被除外时特殊召唤并破坏对方卡片并给予伤害’三个效果。
function s.initial_effect(c)
	-- 添加同调召唤手续：以任意调整加上任意调整以外的怪兽1只以上作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡只要在怪兽区域存在，不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己场上的昆虫族同调怪兽的攻击力上升自己的除外状态的昆虫族怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被除外的场合才能发动。这张卡特殊召唤。那之后，可以把最多有自己的除外状态的昆虫族怪兽数量的对方场上的卡破坏。那个场合，再给与对方破坏数量×500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- e2的影响对象筛选：只适用于自己场上的昆虫族同调怪兽。
function s.atktg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_INSECT)
end
-- 筛选条件：表侧表示且昆虫族的卡，用于统计除外状态中的昆虫族怪兽数量。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- e2的攻击力上升数值：取该怪兽控制者除外区域的表侧昆虫族怪兽数量乘以200。
function s.atkval(e,c)
	-- 返回除外区域表侧昆虫族怪兽数量×200，作为②效果对每只适用怪兽的攻击力上升值。
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_REMOVED,0,nil)*200
end
-- ③效果的发动条件判定：这张卡被除外时，若自己主要怪兽区域有空位且这张卡能被特殊召唤，则允许发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区域存在空位，并且这张卡可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果操作包含特殊召唤这张卡的信息，供其他连锁效果参照。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果处理：先将这张卡特殊召唤；若成功，则根据除外昆虫族数量选择是否破坏对方场上卡片；若破坏了卡，再给予对方破坏数量×500伤害。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡仍与效果相关且特殊召唤成功；若返回非0则说明特殊召唤成功，继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 统计自己当前除外状态的表侧昆虫族怪兽数量，作为可选破坏对方卡片的数量上限。
		local ct=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_REMOVED,0,nil)
		-- 获取对方场上的全部卡片，作为可能被破坏的对象集合。
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 若存在除外昆虫族怪兽且对方场上有卡，则询问玩家是否选择破坏对方的卡。
		if ct>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选对方的卡破坏？"
			-- 中断当前效果链，使特殊召唤后的破坏处理作为独立时点进行，避免错过时点。
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡，显示‘请选择要破坏的卡’的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,ct,nil)
			-- 显示所选择的破坏对象卡的选中动画，并记录这些卡成为效果对象。
			Duel.HintSelection(sg)
			-- 以效果原因破坏所选卡片，返回实际被破坏的数量。
			local dam=Duel.Destroy(sg,REASON_EFFECT)
			if dam>0 then
				-- 再次中断效果链，使破坏与伤害处理分别作为独立时点进行，以正确触发相关时点。
				Duel.BreakEffect()
				-- 给予对方玩家破坏数量×500的效果伤害。
				Duel.Damage(1-tp,dam*500,REASON_EFFECT)
			end
		end
	end
end
