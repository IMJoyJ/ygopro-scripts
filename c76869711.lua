--六花来々
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「六花」怪兽存在的场合才能发动。从卡组选1张「六花」魔法·陷阱卡在自己的魔法与陷阱区域盖放。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
-- ②：1回合1次，自己为让「六花」卡的效果发动而把自己场上的植物族怪兽解放的场合，可以作为自己场上1只植物族怪兽的代替而把对方场上1只表侧表示怪兽解放。
function c76869711.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「六花」怪兽存在的场合才能发动。从卡组选1张「六花」魔法·陷阱卡在自己的魔法与陷阱区域盖放。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,76869711)
	e2:SetCondition(c76869711.stcon)
	e2:SetTarget(c76869711.sttg)
	e2:SetOperation(c76869711.stop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己为让「六花」卡的效果发动而把自己场上的植物族怪兽解放的场合，可以作为自己场上1只植物族怪兽的代替而把对方场上1只表侧表示怪兽解放。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	-- 设置代替解放的适用对象为对方场上的任意怪兽
	e3:SetTarget(aux.TRUE)
	e3:SetCountLimit(1)
	e3:SetValue(c76869711.relval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(76869711)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的「六花」怪兽
function c76869711.filter(c)
	return c:IsSetCard(0x141) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上存在表侧表示的「六花」怪兽
function c76869711.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「六花」怪兽
	return Duel.IsExistingMatchingCard(c76869711.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中可盖放的「六花」魔法·陷阱卡（排除场地魔法）
function c76869711.stfilter(c)
	return c:IsSetCard(0x141) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSSetable()
end
-- ①效果的发动准备：检查魔陷区是否有空位，且卡组中是否存在可盖放的「六花」魔陷
function c76869711.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且卡组中存在至少1张可盖放的「六花」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c76869711.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的效果处理：从卡组选1张「六花」魔陷在自己的魔陷区盖放，并适用特殊召唤限制
function c76869711.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己魔陷区是否有空余位置
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张满足条件的「六花」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c76869711.stfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡片在自己的魔法与陷阱区域盖放
			Duel.SSet(tp,tc)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c76869711.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册直到回合结束时生效的特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤植物族怪兽
function c76869711.splimit(e,c)
	return not c:IsRace(RACE_PLANT)
end
-- 代替解放的判定条件：必须是为发动「六花」卡的效果而作为代价（COST）将怪兽解放
function c76869711.relval(e,re,r,rp)
	return re:IsActivated() and re:GetHandler():IsSetCard(0x141) and bit.band(r,REASON_COST)~=0
end
