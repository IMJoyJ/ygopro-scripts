--No.57 奮迅竜トレスラグーン
-- 效果：
-- 4星怪兽×3
-- ①：这张卡特殊召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的攻击力数值。
-- ②：对方场上的卡数量比自己场上的卡多的场合，把这张卡1个超量素材取除，指定没有使用的怪兽区域或者没有使用的魔法与陷阱区域1处才能发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，指定的区域不能使用。
function c53244294.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：使用3只4星怪兽叠放来进行超量召唤，对应召唤条件“4星怪兽×3”。
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53244294,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c53244294.atktg)
	e1:SetOperation(c53244294.atkop)
	c:RegisterEffect(e1)
	-- ②：对方场上的卡数量比自己场上的卡多的场合，把这张卡1个超量素材取除，指定没有使用的怪兽区域或者没有使用的魔法与陷阱区域1处才能发动。这张卡得到以下效果。●只要这张卡在怪兽区域存在，指定的区域不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53244294,1))  --"区域封锁"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c53244294.zcon)
	e2:SetCost(c53244294.zcost)
	e2:SetTarget(c53244294.ztg)
	e2:SetOperation(c53244294.zop)
	c:RegisterEffect(e2)
end
-- 在全局表中登记此卡的No.编号为57，用于No.卡相关规则判定。
aux.xyz_number[53244294]=57
-- 效果①的目标选择函数：在特殊召唤成功的时点，检查能否以对方场上表侧表示怪兽为对象，并让玩家选择1只对方表侧表示怪兽作为效果对象。
function c53244294.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：确认对方场上存在至少1只表侧表示怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送提示消息，要求其选择一张表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从对方场上选择1只表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①处理时的操作：取得对象怪兽，若发动怪兽和对象怪兽均仍在场上且为表侧表示，则给发动怪兽赋予攻击力上升效果，上升数值等于对象怪兽当前的攻击力。
function c53244294.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁上登记的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的攻击力上升那只怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件判断函数：判断对方场上的卡数量是否多于自己场上的卡数量。
function c53244294.zcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较对方场上与己方场上的卡数量，若对方场上的卡数量大于己方，则条件成立，允许发动效果②。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- 效果②的代价处理函数：检查并移除这张卡的1个超量素材作为发动代价。
function c53244294.zcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动合法性检查：统计双方场上所有可用的怪兽区域和魔法陷阱区域空格，确认至少存在1个可指定区域。
function c53244294.ztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己场上主要怪兽区域的可用空格数。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 加上对方场上主要怪兽区域的可用空格数。
		+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 加上自己场上魔法与陷阱区域的可用空格数。
		+Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
		-- 加上对方场上魔法与陷阱区域的可用空格数，并判断四个数值之和是否大于0；大于0才允许发动。
		+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
	-- 让操作玩家从双方场上选择1个未使用的区域（怪兽区域或魔法与陷阱区域），返回表示该位置的位标记dis。
	local dis=Duel.SelectDisableField(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0xe000e0)
	e:SetLabel(dis)
	-- 向双方玩家展示所选封锁区域，显示将要无效的格子位置。
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- 效果②处理时的操作：将选定的区域位标记保存，若操作方为对方玩家则交换高低16位以转换视角，然后生成一个使指定区域不能使用的永续效果并注册给这张卡。
function c53244294.zop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	-- ●只要这张卡在怪兽区域存在，指定的区域不能使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e:GetHandler():RegisterEffect(e1)
end
