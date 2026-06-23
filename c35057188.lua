--B・F－革命のグラン・パルチザン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不会被效果破坏。
-- ②：自己场上的昆虫族同调怪兽的攻击力上升自己的除外状态的昆虫族怪兽数量×200。
-- ③：这张卡被除外的场合才能发动。这张卡特殊召唤。那之后，可以把最多有自己的除外状态的昆虫族怪兽数量的对方场上的卡破坏。那个场合，再给与对方破坏数量×500伤害。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续、启用复活限制、注册三个效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：这张卡只要在怪兽区域存在，不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果②：自己场上的昆虫族同调怪兽的攻击力上升自己的除外状态的昆虫族怪兽数量×200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 效果③：这张卡被除外的场合才能发动。这张卡特殊召唤。那之后，可以把最多有自己的除外状态的昆虫族怪兽数量的对方场上的卡破坏。那个场合，再给与对方破坏数量×500伤害
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
-- 判断目标是否为昆虫族同调怪兽
function s.atktg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_INSECT)
end
-- 过滤满足条件的除外昆虫族怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 计算攻击力提升值，等于除外的昆虫族怪兽数量×200
function s.atkval(e,c)
	-- 返回除外的昆虫族怪兽数量乘以200作为攻击力提升值
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_REMOVED,0,nil)*200
end
-- 设置效果③的发动条件，检查是否有足够的场地位置和是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场地位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③的处理函数，执行特殊召唤并可能破坏对方卡片并造成伤害
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取己方除外区昆虫族怪兽数量
		local ct=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_REMOVED,0,nil)
		-- 获取对方场上的所有卡片组
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 判断是否满足发动效果③的条件，包括除外昆虫族怪兽数量大于0、对方场上存在卡片、玩家选择是否破坏
		if ct>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选对方的卡破坏？"
			-- 中断当前效果处理，使后续效果视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,ct,nil)
			-- 显示选中的卡片被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 破坏选中的卡片，返回实际破坏的卡片数量
			local dam=Duel.Destroy(sg,REASON_EFFECT)
			if dam>0 then
				-- 再次中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				-- 对对方造成破坏数量乘以500的伤害
				Duel.Damage(1-tp,dam*500,REASON_EFFECT)
			end
		end
	end
end
