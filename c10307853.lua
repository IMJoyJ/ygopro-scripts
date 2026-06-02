--護石の作庭
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的魔法与陷阱区域有卡5张存在，双方受到的战斗伤害变成一半，1回合1次，自己可以把1张永续陷阱卡在盖放的回合发动。
-- ②：自己·对方的准备阶段才能发动。把5张卡名不同的永续陷阱卡从卡组给对方观看，对方从那之中随机选1张。自己把那1张在自己场上盖放，剩余回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果与属性注册
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己的魔法与陷阱区域有卡5张存在，双方受到的战斗伤害变成一半，1回合1次，自己可以把1张永续陷阱卡在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"适用「护石的作庭」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.actcon)
	e2:SetTargetRange(LOCATION_SZONE,0)
	-- 设置允许在盖放回合发动的卡片类型过滤为永续陷阱卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_CONTINUOUS))
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
	-- ①：只要自己的魔法与陷阱区域有卡5张存在，双方受到的战斗伤害变成一半
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,1)
	e3:SetValue(HALF_DAMAGE)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	-- ②：自己·对方的准备阶段才能发动。把5张卡名不同的永续陷阱卡从卡组给对方观看，对方从那之中随机选1张。自己把那1张在自己场上盖放，剩余回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤魔法与陷阱区域前5个格子（非场地魔陷区域）的卡片过滤函数
function s.cfilter(c)
	return c:GetSequence()<5
end
-- 判定自己魔法与陷阱区域是否有5张卡存在的条件判定函数
function s.actcon(e)
	-- 判定自己魔法与陷阱区域中满足特定格子序号条件的卡片是否达到5张
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,5,nil)
end
-- 过滤卡组中可以盖放的永续陷阱卡过滤函数
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 效果2的发动目标判定与可行性检查（检查魔法与陷阱区是否有空位且卡组存在5种不同卡名的永续陷阱）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中所有符合盖放条件的永续陷阱卡
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	-- 效果2发动检查：自己场上必须有空余的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and g:GetClassCount(Card.GetCode)>=5 end
end
-- 效果2的效果处理逻辑（展示5张卡名不同的永续陷阱，由对方随机选1张盖放，其余卡片洗回卡组）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取自己卡组中所有符合盖放条件的永续陷阱卡片组
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	-- 确认自己场上仍有魔陷区空位且卡组中存在至少5种卡名不同的可盖放永续陷阱
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetClassCount(Card.GetCode)>=5 then
		-- 给玩家显示选择要盖放卡片的系统提示文字
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组中选择5张卡名互不相同的卡片
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,5,5)
		-- 向对方玩家出示并展示被选中的5张永续陷阱卡
		Duel.ConfirmCards(1-tp,sg)
		-- 给对方玩家显示选择盖放卡片的系统提示文字
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 将剩余卡片返回卡组后，手动洗切玩家卡组
		Duel.ShuffleDeck(tp)
		-- 将对方玩家随机选出的那1张卡片盖放到自己的场上
		Duel.SSet(tp,tg,tp,false)
	end
end
