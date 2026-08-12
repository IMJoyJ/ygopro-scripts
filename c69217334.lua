--ブレイク・オブ・ザ・ワールド
-- 效果：
-- ①：1回合1次，以自己场上1只仪式怪兽为对象才能发动。手卡1只仪式怪兽直到回合结束时公开。那只公开的仪式怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
-- ②：1回合1次，自己场上有「破灭之女神 露茵」或者「终焉之王 迪米斯」仪式召唤的场合，可以从以下效果选择1个发动。
-- ●自己从卡组抽1张。
-- ●选场上1张卡破坏。
function c69217334.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只仪式怪兽为对象才能发动。手卡1只仪式怪兽直到回合结束时公开。那只公开的仪式怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69217334,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c69217334.lvtg)
	e2:SetOperation(c69217334.lvop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上有「破灭之女神 露茵」或者「终焉之王 迪米斯」仪式召唤的场合，可以从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c69217334.condition)
	e3:SetTarget(c69217334.target)
	c:RegisterEffect(e3)
end
-- 过滤自己场上的表侧表示仪式怪兽，且手卡存在可以公开的、等级不同的仪式怪兽
function c69217334.lvfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
		-- 检查手卡是否存在至少1张满足过滤条件（与该怪兽等级不同且未公开的仪式怪兽）的卡
		and Duel.IsExistingMatchingCard(c69217334.lvcfilter,tp,LOCATION_HAND,0,1,nil,c)
end
-- 过滤手卡中未公开的、且等级与目标怪兽不同的仪式怪兽
function c69217334.lvcfilter(c,mc)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
		and not c:IsLevel(mc:GetLevel())
end
-- 效果①的发动准备，用于选择自己场上1只表侧表示的仪式怪兽作为对象
function c69217334.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c69217334.lvfilter(chkc,tp) end
	-- 检查自己场上是否存在可以作为效果对象的仪式怪兽
	if chk==0 then return Duel.IsExistingTarget(c69217334.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只仪式怪兽作为对象
	local g=Duel.SelectTarget(tp,c69217334.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果①的处理，公开手卡1只仪式怪兽并改变其等级
function c69217334.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要给对方确认（公开）的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡1只满足条件的仪式怪兽
	local cg=Duel.SelectMatchingCard(tp,c69217334.lvcfilter,tp,LOCATION_HAND,0,1,1,nil,tc)
	if cg:GetCount()>0 then
		-- 向对方玩家展示（公开）所选的手卡
		Duel.ConfirmCards(1-tp,cg)
		local pc=cg:GetFirst()
		-- 手卡1只仪式怪兽直到回合结束时公开。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(66)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PUBLIC)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		pc:RegisterEffect(e2)
		if tc:IsRelateToEffect(e) then
			-- 那只公开的仪式怪兽的等级直到回合结束时变成和作为对象的怪兽的等级相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			pc:RegisterEffect(e1)
		end
	end
end
-- 过滤在自己场上仪式召唤成功的「破灭之女神 露茵」或「终焉之王 迪米斯」
function c69217334.cfilter(c,tp)
	return c:IsCode(46427957,72426662) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果②的发动条件：自己场上有「破灭之女神 露茵」或者「终焉之王 迪米斯」仪式召唤成功的场合
function c69217334.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c69217334.cfilter,1,nil,tp)
end
-- 效果②的发动准备，让玩家选择并声明要发动的分支效果（抽卡或破坏）
function c69217334.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以进行抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1)
	-- 获取场上所有的卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	local b2=g:GetCount()>0
	if chk==0 then return b1 or b2 end
	local sel=0
	-- 提示玩家选择要发动的效果分支
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if b1 and b2 then
		-- 玩家选择“自己从卡组抽1张”或“选场上1张卡破坏”中的一个效果
		sel=Duel.SelectOption(tp,aux.Stringid(69217334,0),aux.Stringid(69217334,1))  --"自己从卡组抽1张/选场上1张卡破坏"
	elseif b1 then
		-- 玩家只能选择“自己从卡组抽1张”效果
		sel=Duel.SelectOption(tp,aux.Stringid(69217334,0))  --"自己从卡组抽1张"
	else
		-- 玩家只能选择“选场上1张卡破坏”效果（索引值加1以匹配分支判断）
		sel=Duel.SelectOption(tp,aux.Stringid(69217334,1))+1  --"选场上1张卡破坏"
	end
	if sel==0 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
		e:SetOperation(c69217334.drop)
		-- 设置当前效果的目标玩家为自己
		Duel.SetTargetPlayer(tp)
		-- 设置当前效果的目标参数为1（抽1张卡）
		Duel.SetTargetParam(1)
		-- 设置连锁的操作信息为：玩家tp从卡组抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetOperation(c69217334.desop)
		-- 设置连锁的操作信息为：破坏场上的1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 抽卡分支效果的处理函数
function c69217334.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行因效果让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 破坏分支效果的处理函数
function c69217334.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家选择场上任意1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 破坏所选的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
