--魔導天士 トールモンド
-- 效果：
-- 这张卡用魔法师族怪兽或者名字带有「魔导书」的魔法卡的效果特殊召唤成功时，可以选择自己墓地2张名字带有「魔导书」的魔法卡加入手卡。这个效果发动的回合，自己不能把其他怪兽特殊召唤。这个效果把卡加入手卡时，把手卡的名字带有「魔导书」的魔法卡4种类给对方观看才能发动。这张卡以外的场上的卡全部破坏。
function c29146185.initial_effect(c)
	-- 这张卡用魔法师族怪兽或者名字带有「魔导书」的魔法卡的效果特殊召唤成功时，可以选择自己墓地2张名字带有「魔导书」的魔法卡加入手卡。这个效果发动的回合，自己不能把其他怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29146185,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c29146185.retcon)
	e1:SetCost(c29146185.retcost)
	e1:SetTarget(c29146185.rettg)
	e1:SetOperation(c29146185.retop)
	c:RegisterEffect(e1)
	-- 这个效果把卡加入手卡时，把手卡的名字带有「魔导书」的魔法卡4种类给对方观看才能发动。这张卡以外的场上的卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29146185,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CUSTOM+29146185)
	e2:SetCost(c29146185.descost)
	e2:SetTarget(c29146185.destg)
	e2:SetOperation(c29146185.desop)
	c:RegisterEffect(e2)
end
-- 判定本卡是否满足发动条件：确认本次特殊召唤所用的素材/效果种类，若其属于魔法师族怪兽或名字带有「魔导书」的魔法卡的效果，则允许回手效果发动。
function c29146185.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local typ,race=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return (typ&TYPE_MONSTER~=0 and race&RACE_SPELLCASTER~=0) or (typ&TYPE_SPELL~=0 and c:IsSpecialSummonSetCard(0x106e))
end
-- 回手效果的发动代价处理：检查本回合特殊召唤次数为1，并给自己附加“不能特殊召唤怪兽”的直到结束阶段的限制效果，以对应‘这个效果发动的回合，自己不能把其他怪兽特殊召唤’。
function c29146185.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost检查阶段确认tp本回合的特殊召唤次数是否为1，即本次特殊召唤是本回合唯一一次特殊召唤（没有其他特殊召唤发生过）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==1 end
	-- 这张卡用魔法师族怪兽或者名字带有「魔导书」的魔法卡的效果特殊召唤成功时，可以选择自己墓地2张名字带有「魔导书」的魔法卡加入手卡。这个效果发动的回合，自己不能把其他怪兽特殊召唤。这个效果把卡加入手卡时，把手卡的名字带有「魔导书」的魔法卡4种类给对方观看才能发动。这张卡以外的场上的卡全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将刚创建的自肃效果e1注册到当前玩家tp身上，使‘不能特殊召唤怪兽’的限制生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义墓地卡片的筛选条件：卡名带有「魔导书」字段的魔法卡，并且该卡可以被加入手卡。
function c29146185.filter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 回手效果发动时的目标处理：选择自己墓地2张满足条件的「魔导书」魔法卡作为效果对象，并设置将卡加入手卡的操作信息。
function c29146185.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29146185.filter(chkc) end
	-- 检查自己墓地是否存在至少2张满足条件的「魔导书」魔法卡，作为回手效果能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c29146185.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家显示选择提示，提示内容为‘请选择要返回手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己墓地选择2张满足条件的「魔导书」魔法卡，并将这些卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c29146185.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置本次连锁的操作信息：将选择的2张卡加入手卡，供相关效果检测（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 回手效果的处理：将对象卡送回持有者手卡，若成功则向对方展示这些卡，并触发自定义事件EVENT_CUSTOM+29146185，以便后续‘把卡加入手卡时’的破坏效果发动。
function c29146185.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取得发动时选择的对象卡，并筛选出仍然与该效果有联系的卡（未离场且联系未被重置）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若这些卡实际成功送回手卡的数量大于0，则继续执行后续的确认和触发破坏效果。
	if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 将回收到手卡的「魔导书」魔法卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 以本卡为触发源触发自定义事件EVENT_CUSTOM+29146185，用于在‘这个效果把卡加入手卡时’的时点发动后续破坏效果。
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+29146185,re,r,rp,0,0)
		end
	end
end
-- 定义手牌卡片的筛选条件：卡名带有「魔导书」字段的魔法卡，且当前没有公开（非双方公开确认的状态）。
function c29146185.cffilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 破坏效果的发动代价处理：从手牌选择4张卡名互不相同的名字带有「魔导书」的魔法卡（即4种类）给对方展示，然后洗切手牌。
function c29146185.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手牌中所有满足条件的「魔导书」魔法卡（未公开），构成候选卡组。
	local g=Duel.GetMatchingGroup(c29146185.cffilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=4 end
	-- 给玩家显示选择提示，提示内容为‘请选择给对方确认的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从候选卡组中选择4张卡名互不相同的「魔导书」魔法卡（即4种类）作为给对方展示的对象。
	local cg=g:SelectSubGroup(tp,aux.dncheck,false,4,4)
	-- 将选出的4张手牌展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,cg)
	-- 展示手牌后洗切手牌，避免对方通过展示顺序获知手牌的排列信息。
	Duel.ShuffleHand(tp)
end
-- 破坏效果发动时的目标处理：确认场上存在除本卡以外的卡，并将场上除本卡以外的所有卡设为破坏对象范围，设置破坏操作信息。
function c29146185.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张除本卡以外的卡，作为破坏效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上除本卡以外的所有卡，用于登记操作信息中的破坏对象范围（不取对象）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置本次连锁的操作信息：将场上除本卡以外的所有卡全部破坏，数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：获取场上除本卡以外的所有卡，并将它们全部破坏。
function c29146185.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除本卡以外的所有卡，作为实际破坏的目标组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果原因破坏目标组中的所有卡。
	Duel.Destroy(g,REASON_EFFECT)
end
