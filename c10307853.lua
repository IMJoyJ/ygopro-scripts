--護石の作庭
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的魔法与陷阱区域有卡5张存在，双方受到的战斗伤害变成一半，1回合1次，自己可以把1张永续陷阱卡在盖放的回合发动。
-- ②：自己·对方的准备阶段才能发动。把5张卡名不同的永续陷阱卡从卡组给对方观看，对方从那之中随机选1张。自己把那1张在自己场上盖放，剩余回到卡组。
local s,id,o=GetID()
-- 卡片效果注册：在卡片初始化时，注册该永续魔法的发动效果、战斗伤害减半效果、永续陷阱卡盖放回合发动的效果，以及在双方准备阶段从卡组盖放永续陷阱卡的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己可以把1张永续陷阱卡在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"适用「护石的作庭」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.actcon)
	e2:SetTargetRange(LOCATION_SZONE,0)
	-- 设定该效果的目标为永续卡片类型（在此指永续陷阱）
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
-- 过滤出位于魔法与陷阱区域前5格（主要魔法与陷阱区域）的卡片
function s.cfilter(c)
	return c:GetSequence()<5
end
-- ①之效果的适用条件判定：自己场上前5格的魔法与陷阱区域均有卡存在
function s.actcon(e)
	-- 判定自己场上的主要魔法与陷阱区域是否刚好有5张卡存在
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,5,nil)
end
-- 过滤出卡组中可以盖放的永续陷阱卡
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsSSetable()
end
-- ②之效果的发动准备：检查场上空格以及卡组中不同名永续陷阱卡的种类数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有符合盖放条件的永续陷阱卡
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	-- 判断自己魔法与陷阱区域是否存在至少一个可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and g:GetClassCount(Card.GetCode)>=5 end
end
-- ②之效果的效果处理：从卡组选择5张不同名的永续陷阱卡给对方确认，对方随机选择1张在自己场上盖放，其余卡片洗回卡组
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合盖放条件的永续陷阱卡
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	-- 判断自己魔法与陷阱区域是否有空位，且卡组中存在至少5种不同卡名的永续陷阱卡时继续进行效果处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetClassCount(Card.GetCode)>=5 then
		-- 提示玩家选择要盖放并向对方出示的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从符合条件的卡片中选择5张卡名互不相同的永续陷阱卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,5,5)
		-- 将选择的5张永续陷阱卡给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 将自己卡组重新洗牌
		Duel.ShuffleDeck(tp)
		-- 将对方随机选择的1张永续陷阱卡盖放在自己场上
		Duel.SSet(tp,tg,tp,false)
	end
end
