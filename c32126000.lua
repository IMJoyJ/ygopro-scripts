--ラーニング・エルフ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把持有把自身当作装备卡使用来装备效果的1张陷阱卡从卡组到自己场上盖放。
-- ②：这张卡从场上送去墓地的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 定义学习精灵的效果注册入口，创建并注册①效果（召唤/特殊召唤成功时从卡组盖放符合条件的陷阱）和②效果（从场上送去墓地时抽1），并分别用id和id+o设置1回合1次限制；其中e2是e1的克隆，仅将触发事件改为特殊召唤成功。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。把持有把自身当作装备卡使用来装备效果的1张陷阱卡从卡组到自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放效果"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡从场上送去墓地的场合才能发动。自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 定义效果过滤器，判断一个效果是否带有CATEGORY_EQUIP分类，即是否具有“把自身当作装备卡使用来装备”的效果。
function s.equip_filter(e)
	return e:IsHasCategory(CATEGORY_EQUIP)
end
-- 筛选符合条件的卡：必须是陷阱卡、可以盖放到魔陷区、并且其原始效果中含有“把自身当作装备卡使用来装备”的分类。
function s.ssfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable() and c:IsOriginalEffectProperty(s.equip_filter)
end
-- ①效果的发动条件检查：在自己的魔陷区有空位，且卡组中存在至少1张满足条件的陷阱卡时才能发动。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己的魔法与陷阱区域存在可使用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件之二：卡组中存在至少1张满足s.ssfilter筛选条件的陷阱卡。
		and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理时，若魔陷区仍有空位，则从卡组选择1张符合条件的陷阱卡并盖放到自己场上。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认魔陷区空格数，若已无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 向操作玩家发送选择卡牌的提示消息，提示内容为“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己卡组中筛选并选择1张满足s.ssfilter条件的陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡以里侧表示盖放到自己的魔法与陷阱区域。
		Duel.SSet(tp,g)
	end
end
-- ②效果的发动条件：这张卡在从场上送去墓地之前位于场上，即确实是从场上区域进入墓地。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的目标设置：确认自己可以抽1张卡，然后将本次连锁的对象玩家设为自己、抽卡数设为1，并登记抽卡操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为发动玩家自身。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽1张卡。
	Duel.SetTargetParam(1)
	-- 向系统登记当前连锁的操作信息：这是一个抽卡效果，对象为自己，预定抽1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理时，从连锁信息中取出对象玩家和抽卡张数，并执行实际的抽卡操作。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取登记的对象玩家和对象参数（抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因抽取指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
