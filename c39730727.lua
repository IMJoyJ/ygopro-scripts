--天威無崩の地
-- 效果：
-- ①：只要这张卡在场地区域存在，效果怪兽以外的场上的表侧表示怪兽不受怪兽的效果影响。
-- ②：1回合1次，对方把效果怪兽特殊召唤的场合，若自己场上有效果怪兽以外的怪兽存在则能发动。自己抽2张。
function c39730727.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，效果怪兽以外的场上的表侧表示怪兽不受怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c39730727.etarget)
	e2:SetValue(c39730727.efilter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把效果怪兽特殊召唤的场合，若自己场上有效果怪兽以外的怪兽存在则能发动。自己抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c39730727.drcon)
	e3:SetTarget(c39730727.drtg)
	e3:SetOperation(c39730727.drop)
	c:RegisterEffect(e3)
end
-- 免疫效果的适用对象筛选：判断怪兽是否为效果怪兽以外的怪兽（非效果怪兽），是则作为本卡的免疫保护对象，不受怪兽效果影响。
function c39730727.etarget(e,c)
	return not c:IsType(TYPE_EFFECT)
end
-- 免疫效果的过滤条件：判断即将生效的效果是否为怪兽的效果，若是怪兽效果则对其免疫。
function c39730727.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判定怪兽是否满足“效果怪兽以外的怪兽”：表侧表示且不是效果怪兽，或者里侧表示（此时不公开怪兽种类）即视为满足条件，用于检查自己场上是否存在可触发②的怪兽。
function c39730727.drfilter1(c)
	return (not c:IsType(TYPE_EFFECT) and c:IsFaceup()) or c:IsFacedown()
end
-- 筛选对方特殊召唤成功的怪兽中，属于对方（1-tp）特殊召唤的表侧表示效果怪兽，用于触发②的场合条件。
function c39730727.drfilter2(c,tp)
	return c:IsType(TYPE_EFFECT) and c:IsSummonPlayer(1-tp) and c:IsFaceup()
end
-- ②的发动条件：自己场上存在效果怪兽以外的怪兽，且本次特殊召唤成功的怪兽中有对方特殊召唤的效果怪兽。
function c39730727.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足drfilter1条件的怪兽（效果怪兽以外的怪兽）。
	return Duel.IsExistingMatchingCard(c39730727.drfilter1,tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(c39730727.drfilter2,1,nil,tp)
end
-- ②的发动目标处理：确认自己能够抽2张卡，将抽卡玩家设为自己、抽卡数设为2，并登记抽卡的操作信息。
function c39730727.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己是否可以通过效果抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本次效果的对象玩家设为自己，即后续抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的对象参数设为2，即抽卡数量为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：声明本连锁将执行由tp玩家抽2张卡的处理，供其他效果（如抽卡限制、替代效果）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②的效果处理：取出发动时登记的抽卡玩家和抽卡数量，让该玩家抽对应数量的卡。
function c39730727.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时设定的对象玩家（p）和对象参数（d），即抽卡的玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡，完成②的抽卡处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
